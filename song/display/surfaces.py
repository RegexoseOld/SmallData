import pygame


class Beat(pygame.Surface):
    __text_surf = None

    def __init__(self,
                 size=(100, 100),
                 background_color=(190, 190, 190),
                 font_color=(140, 40, 240),
                 font_size=80):
        super(Beat, self).__init__(size)
        self.background_color = background_color
        self.font_color = font_color
        self.font_size = font_size
        self.font = pygame.font.Font(None, self.font_size)

        self.fill(self.background_color)
        self.update('1')
        self.render(self)

    def update(self, string):
        #  change the content of the display
        self.fill(self.background_color)
        self.__text_surf = self.font.render(string, 1, self.font_color)
        self.blit(self.__text_surf, (0, 0))

    def render(self, screen, pos=(0, 0)):
        screen.blit(self, pos)
