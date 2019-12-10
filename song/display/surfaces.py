import pygame


background_color = 190, 190, 190
font_color = 140, 40, 240
font_size = 80
font = pygame.font.Font(None, font_size)


class Beat(pygame.Surface):
    __text_surf = None

    def __init__(self, size=(100, 100)):
        super(Beat, self).__init__(size)
        self.fill(background_color)
        self.update('1')
        self.render(self)

    def update(self, string):
        #  change the content of the display
        self.fill(background_color)
        self.__text_surf = font.render(string, 1, font_color)
        self.blit(self.__text_surf, (0, 0))

    def render(self, screen, pos=(0, 0)):
        screen.blit(self, pos)
