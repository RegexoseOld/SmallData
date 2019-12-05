from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client
from collections import OrderedDict
import time

import pickle
import asyncio
import pygame

INTERPRETER_TARGET_ADDRESS = "/interpreter_input"
INTERPRETER_PORT = 5020
OSCULATOR_PORT = 5010

pygame.init()
pygame.font.init()
font = pygame.font.Font(None, 25)

ip = "127.0.0.1"


size = width, height = 800, 800
height_textsurface = height / 2
width_text = width / 2
width_cat = width/4

black = 0, 0, 0
grey = 227, 227, 227
font_color = 155, 155, 0
refresh_rate = 10.  # Hz


class SongServer:
    server = None

    def __init__(self, client, machine, songgraphic):
        self.osculator_client = client
        self._song_machine = machine
        self.song_graphic = songgraphic
        self.song_scenes = {k : v for k, v in zip(
            self._song_machine.parser.states,
            range(len(self._song_machine.parser.states)
                  ))}

        self.screen = pygame.display.set_mode(size)
        pygame.display.set_caption('Status Screen')
        self.text_surface = pygame.Surface((width_text, height_textsurface))
        self.text_surface.fill(grey)

        self.cat_surface = pygame.Surface((width_cat, height_textsurface))
        self.cat_surface.fill(grey)

        self.text_positions = OrderedDict()
        self.song_state_surf = font.render('No State Received', False, font_color)

        text_output_surf = font.render('No Interpretation Received', 1, font_color)
        self.text_surface.blit(text_output_surf, (0, 0))
        self.osculator_client.send_message('/advance', (0, 1.0))
        self.osculator_client.send_message('/advance', (0, 0.0))

    def _position_text_display(self, text_surface, cat_surface):
        new_height = text_surface.get_rect().height
        to_remove = []
        for surfaces in self.text_positions:
            self.text_positions[surfaces] += new_height
            if self.text_positions[surfaces] > height_textsurface:
                to_remove.append(surfaces)

        self.text_positions[(text_surface, cat_surface)] = 0

        # remove surfaces outside of drawing area
        [self.text_positions.pop(surfaces) for surfaces in to_remove]

        # blit
        self.text_surface.fill(grey)
        self.cat_surface.fill(grey)

        for (text, cat), y_pos in self.text_positions.items():
            self.text_surface.blit(text, (0, y_pos))
            self.cat_surface.blit(cat, (0, y_pos))

    def _update_display_objects(self, osc_map):
        text_output_surf = linebreak(osc_map['text'], font_color, self.text_surface.get_rect(), font, 1)
        cat_output_surf = linebreak(osc_map['cat'], font_color, self.cat_surface.get_rect(), font, 1)

        self.song_state_surf = font.render('Current Part {}'. format(self._song_machine.current_state.name),
                                           True, font_color)
        self._position_text_display(text_output_surf, cat_output_surf)
        self.song_graphic.playhead.handle_input_data(self._song_machine.current_state.name)

    def _update_song(self, osc_map):
        level = osc_map['level']
        self.osculator_client.send_message('/rack', (level / 10))
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 1.0))
        
        self.osculator_client.send_message('/osc_notes', (level + 90, 100, 0.0))
        current_state = self._song_machine.current_state
        self._song_machine.update_state(osc_map['cat'])
        if current_state != self._song_machine.current_state:
            self.advance_to_scene = self.song_scenes[self._song_machine.current_state.name]
            print('update with status: {}\ncurrent_state: {}\nadvance_to_scene: {}'
                  .format(
                osc_map['cat'],
                self._song_machine.current_state.name,
                self.advance_to_scene))
            self.osculator_client.send_message('/advance', (self.advance_to_scene, 1.0))
            self.osculator_client.send_message('/advance', (self.advance_to_scene, 0.0))

    def message_handler(self, address, content):
        osc_map = pickle.loads(content)
        print('address: {}\nmap: {}'.format(address, osc_map))
        self._update_song(osc_map)
        self._update_display_objects(osc_map)

    async def loop(self):
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    sys.exit()
                elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                    print("escape :::")
                    return False

            self.screen.fill(grey)

            self.screen.blit(self.song_state_surf, (15, 325))
            self.screen.blit(self.text_surface, (15, 350))
            self.screen.blit(self.cat_surface, (15 + width_text, 350))

            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    self.song_graphic.handle_input(event.key)

            self.song_graphic.playhead.handle_input_data(1)  # moves playhead forward
            self.song_graphic.render(self.screen)
            pygame.display.flip()

            await asyncio.sleep(1./refresh_rate)

    async def init_main(self):
        dispatcher = Dispatcher()
        dispatcher.map(INTERPRETER_TARGET_ADDRESS, self.message_handler)

        self.server = AsyncIOOSCUDPServer((ip, INTERPRETER_PORT), dispatcher, asyncio.get_event_loop())
        transport, protocol = await self.server.create_serve_endpoint()  # Create datagram endpoint and start serving
        print('transport {} protocol {}'.format(transport, protocol))
        await self.loop()  # Enter main loop of program

        transport.close()  # Clean up serve endpoint


if __name__ == '__main__':
    osculator_client = udp_client.SimpleUDPClient(ip, OSCULATOR_PORT)

    # add file to path so import works, see https://stackoverflow.com/a/19190695/7414040
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_machine
    from display.status_display import SongStatus
    from display.playhead import Playhead
    from display.font_render import linebreak
    from config import settings

    machine_instance = song_machine.create_instance(settings.song_path)

    playhead = Playhead()
    song_graphic = SongStatus(settings.song_file, machine_instance.parser.data['states'], playhead)

    song_server = SongServer(osculator_client, machine_instance, song_graphic)

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(song_server.init_main())
