import pygame
import sys
import asyncio
import pickle

from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher

from config import settings

pygame.init()
pygame.font.init()
font = pygame.font.Font(None, 25)

size = width, height = 800, 800
black = 0, 0, 0
grey = 227, 227, 227
font_color = 155, 155, 0
refresh_rate = 10.  # Hz


class DisplayServer:
    server = None

    def __init__(self, beat_manager, songgraphic, utterances, beat, part_info):
        self.beat_manager = beat_manager
        self.song_graphic = songgraphic
        self.utterances = utterances
        self.beat = beat
        self.part_info = part_info

        self.screen = pygame.display.set_mode(size)
        pygame.display.set_caption('Status Screen')

    def _update_display_objects(self, osc_map):
        #  TODO: show songs current state
        # self.song_state_surf = font.render('Current Part {}'. format(self._song_machine.current_state.name),
        #                                    True, font_color)
        # self.song_graphic.playhead.handle_input_data(self._song_machine.current_state.name)
        pass

    def message_handler(self, _, content):
        osc_map = pickle.loads(content)
        print("DisplayServer, received {}".format(osc_map))
        self.utterances.update(osc_map)
        self._update_display_objects(osc_map)

    def part_handler(self, _, next_part):
        print("TRIGGERING NEXT PART: {}".format(next_part))
        self.beat_manager.update_next_part(next_part)

    def beat_handler(self, _, note):
        print('DisplayServer: Receiving "{}"'.format(note))
        self.beat_manager.update_beat_counter(note)
        self.beat.update(self.beat_manager.counter, self.beat_manager.is_warning())
        self.part_info.update(current_part=self.beat_manager.current_part,
                              next_part=self.beat_manager.next_part)

    async def loop(self):
        while True:
            self.screen.fill(grey)

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    sys.exit()
                elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                    print("escape :::")
                    return False
                elif event.type == pygame.KEYDOWN:
                    self.song_graphic.handle_input(event.key)

            self.utterances.render(self.screen, pos=(15, 350))
            self.beat.render(self.screen, pos=(600, 50))

            self.song_graphic.update(1)  # moves playhead forward
            self.song_graphic.render(self.screen, pos=(0, 0))

            self.part_info.render(self.screen, pos=(600, 200))

            pygame.display.flip()

            await asyncio.sleep(1./refresh_rate)

    async def init_main(self):
        dispatcher = Dispatcher()
        dispatcher.map(settings.DISPLAY_TARGET_ADDRESS, self.message_handler)
        dispatcher.map(settings.OSCULATOR_TARGET_ADDRESS, self.beat_handler)
        dispatcher.map(settings.SONG_ADVANCE_ADDRESS, self.part_handler)

        self.server = AsyncIOOSCUDPServer((settings.ip, settings.DISPLAY_PORT), dispatcher, asyncio.get_event_loop())
        transport, protocol = await self.server.create_serve_endpoint()  # Create datagram endpoint and start serving
        await self.loop()  # Enter main loop of program

        transport.close()  # Clean up serve endpoint
