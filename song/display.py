from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import pickle
import asyncio
import pygame
import sys


pygame.init()
pygame.font.init()
font = pygame.font.Font(None, 20)

ip = "127.0.0.1"
port = 5020

size = width, height = 420, 240
black = 0, 0, 0
font_color = 155, 155, 0


class Display:
    server = None

    def __init__(self):
        self.screen = pygame.display.set_mode(size)
        self.textsurface = font.render('Nothing received', False, font_color)

    def update(self, _, content):
        osc_map = pickle.loads(content)
        self.textsurface = font.render('Received map: {}'.format(osc_map), True, font_color)

    async def loop(self):
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT: sys.exit()

            self.screen.fill(black)
            self.screen.blit(self.textsurface, (0, 0))
            pygame.display.flip()

            await asyncio.sleep(1)

    async def init_main(self):
        dispatcher = Dispatcher()
        dispatcher.map("/interpreter_input", self.update)

        self.server = AsyncIOOSCUDPServer((ip, port), dispatcher, asyncio.get_event_loop())
        transport, protocol = await self.server.create_serve_endpoint()  # Create datagram endpoint and start serving

        await self.loop()  # Enter main loop of program

        transport.close()  # Clean up serve endpoint


if __name__ == '__main__':
    display = Display()
    asyncio.run(display.init_main())
