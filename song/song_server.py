from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
from pythonosc import udp_client

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


size = width, height = 420, 240
black = 0, 0, 0
font_color = 155, 155, 0
refresh_rate = 10.  # Hz


class SongServer:
    server = None

    def __init__(self, client, machine):
        self.osculator_client = client
        self._song_machine = machine

        self.screen = pygame.display.set_mode(size)
        self.interpreter_output_surf = font.render('Nothing received', False, font_color)
        self.song_state_surf = font.render('Nothing received', False, font_color)

    def _update_display_objects(self, osc_map):
        self.interpreter_output_surf = font.render('Received map: {}'.format(osc_map), True, font_color)
        self.song_state_surf = font.render('Current Part {}'. format(self._song_machine.current_state.name),
                                           True, font_color)

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

            self.screen.fill(black)
            self.screen.blit(self.interpreter_output_surf, (0, 0))
            self.screen.blit(self.song_state_surf, (0, 30))
            pygame.display.flip()

            await asyncio.sleep(1./refresh_rate)

    async def init_main(self):
        dispatcher = Dispatcher()
        dispatcher.map(INTERPRETER_TARGET_ADDRESS, self.message_handler)

        self.server = AsyncIOOSCUDPServer((ip, INTERPRETER_PORT), dispatcher, asyncio.get_event_loop())
        transport, protocol = await self.server.create_serve_endpoint()  # Create datagram endpoint and start serving

        await self.loop()  # Enter main loop of program

        transport.close()  # Clean up serve endpoint


if __name__ == '__main__':
    mock_osculator_client = udp_client.SimpleUDPClient(ip, OSCULATOR_PORT)

    # add file to path so import works, see https://stackoverflow.com/a/19190695/7414040
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
    from song import song_machine

    machine = song_machine.create_instance()

    song_server = SongServer(mock_osculator_client, machine)
    asyncio.run(song_server.init_main())
