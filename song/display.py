from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import asyncio
import pygame
import sys


pygame.init()

ip = "127.0.0.1"
port = 5020

size = width, height = 320, 240
speed = [2, 2]
black = 0, 0, 0


class Display:
    server = None

    def __init__(self):
        self.screen = pygame.display.set_mode(size)

        self.ball = pygame.image.load("/Users/staude/Downloads/intro_ball.gif")
        self.ballrect = self.ball.get_rect()

    def update(self, address, *args):
        self.ballrect = self.ballrect.move(speed)
        if self.ballrect.left < 0 or self.ballrect.right > width:
            speed[0] = -speed[0]
        if self.ballrect.top < 0 or self.ballrect.bottom > height:
            speed[1] = -speed[1]

    async def loop(self):
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT: sys.exit()

            self.screen.fill(black)
            self.screen.blit(self.ball, self.ballrect)
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