import pygame
import sys
import asyncio
import pickle
from collections import OrderedDict

from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher

from song.display.font_render import linebreak
from config import settings


pygame.init()
pygame.font.init()
font = pygame.font.Font(None, 25)

size = width, height = 800, 800
height_textsurface = height / 2
width_text = width / 2
width_cat = width/4

black = 0, 0, 0
grey = 227, 227, 227
font_color = 155, 155, 0

refresh_rate = 10.  # Hz


class DisplayServer:
    server = None

    def __init__(self, songgraphic):
        self.song_graphic = songgraphic

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

        self._position_text_display(text_output_surf, cat_output_surf)
        # self.song_state_surf = font.render('Current Part {}'. format(self._song_machine.current_state.name),
        #                                    True, font_color)
        # self.song_graphic.playhead.handle_input_data(self._song_machine.current_state.name)

    def message_handler(self, _, content):
        osc_map = pickle.loads(content)
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
        dispatcher.map(settings.DISPLAY_TARGET_ADDRESS, self.message_handler)

        self.server = AsyncIOOSCUDPServer((settings.ip, settings.DISPLAY_PORT), dispatcher, asyncio.get_event_loop())
        transport, protocol = await self.server.create_serve_endpoint()  # Create datagram endpoint and start serving
        print('transport {} protocol {}'.format(transport, protocol))
        await self.loop()  # Enter main loop of program

        transport.close()  # Clean up serve endpoint


if __name__ == '__main__':
    from song.display.playhead import Playhead
    from song.display.status_display import SongStatus
    playhead = Playhead()
    #  TODO use actula states of song
    song_graphic = SongStatus(settings.song_file, ["intro", "scene02",  "scene03"], playhead)
    display_server = DisplayServer(song_graphic)

    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(display_server.init_main())
