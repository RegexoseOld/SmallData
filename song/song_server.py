from os import sys, path
sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client
from collections import OrderedDict

import pickle
import asyncio
import pygame

INTERPRETER_TARGET_ADDRESS = "/interpreter_input"
INTERPRETER_PORT = 5020
OSCULATOR_PORT = 5010

pygame.init()
pygame.font.init()
font = pygame.font.Font(None, 20)

ip = "127.0.0.1"


size = width, height = 800, 800
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

        self.screen = pygame.display.set_mode(size)
        pygame.display.set_caption('Status Screen')
        self.text_surface = pygame.Surface((width, height/2))
        self.text_surface.fill(grey)

        self.interpreter_output_surf = font.render('No Interpretation Received', False, font_color)
        self.text_positions = OrderedDict()
        self.pos_y = 0
        self.song_state_surf = font.render('No State Received', False, font_color)
        self.text_surface.blit(self.interpreter_output_surf, (0, 0))

    def _position_text_display(self, text, text_cache=3):
        self.text_positions[text] = text.get_rect().bottom + self.pos_y
        if len(self.text_positions) == text_cache + 1:
            # replace position of text to the position of the frontrunner
            # and delete first key 
            for text, position in self.text_positions.items():
                for index, item in enumerate(:
                if index != 0:
                pass


        self.pos_y = text.get_rect().bottom + self.pos_y
        self.text_surface.blit(text, (0, self.pos_y))


    def _update_display_objects(self, osc_map):
        # self.text_surface.fill(grey)
        self.interpreter_output_surf = font.render('Received map: {}'.format(osc_map), True, font_color)
        self.song_state_surf = font.render('Current Part {}'. format(self._song_machine.current_state.name),
                                           True, font_color)
        self._position_text_display(self.interpreter_output_surf)
        self.song_graphic.playhead.handle_input_data(self._song_machine.current_state.name)

    def _update_song(self, osc_map):
        level = osc_map['level']
        self.osculator_client.send_message('/rack', (level / 10))

        current_state = self._song_machine.current_state
        self._song_machine.update_state(osc_map['cat'])
        if current_state != self._song_machine.current_state:
            self.osculator_client.send_message('/advance', (0, 1.0))  # was braucht Osculator hier?
            self.osculator_client.send_message('/advance', (0, 0.0))

    def message_handler(self, address, content):
        osc_map = pickle.loads(content)
        print('address: {} map: {}'.format(address, osc_map))
        self._update_song(osc_map)
        self._update_display_objects(osc_map)

    async def loop(self):
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT: sys.exit()

            self.screen.fill(grey)

            self.screen.blit(self.song_state_surf, (15, 325))
            self.screen.blit(self.text_surface, (15, 350))

            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    self.song_graphic.handle_input(event.key)

            self.song_graphic.playhead.handle_input_data(1) # moves playhead forward
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
    mock_osculator_client = udp_client.SimpleUDPClient(ip, OSCULATOR_PORT)

    # add file to path so import works, see https://stackoverflow.com/a/19190695/7414040
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_machine
    from src.pygame.status_display import SCREEN_HEIGHT, SCREEN_WIDTH, SongStatus
    from src.pygame.playhead import Playhead

    machine = song_machine.create_instance()

    playhead = Playhead()
    song_graphic = SongStatus('heavy lemon', machine.parser.data['states'], playhead)

    song_server = SongServer(mock_osculator_client, machine, song_graphic)

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(song_server.init_main())
