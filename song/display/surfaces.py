import pygame
from collections import OrderedDict

from config import settings
from song.display.font_render import linebreak


class Beat(pygame.Surface):
    __counter_surf = None

    def __init__(self,
                 size=(100, 100),
                 background_color=(190, 190, 190),
                 normal_font_color=(240, 0, 0),
                 warning_font_color=(0, 240, 0),
                 font_size=80):
        super(Beat, self).__init__(size)
        self.background_color = background_color
        self.normal_font_color = normal_font_color
        self.warning_font_color = warning_font_color
        self.font_size = font_size
        self.font = pygame.font.Font(None, self.font_size)

        self.fill(self.background_color)
        self.update(list(settings.note_to_beat.values())[0], False)
        self.render(self)

    def update(self, counter, is_warning):
        colour = self.warning_font_color if is_warning else self.normal_font_color

        self.fill(self.background_color)
        self.__counter_surf = self.font.render(counter, 1, colour)
        self.blit(self.__counter_surf, (0, 0))

    def render(self, screen, pos=(0, 0)):
        screen.blit(self, pos)


class PartInfo(pygame.Surface):
    __current_surf = None
    __next_surf = None

    def __init__(self,
                 size=(400, 40),
                 background_color=(190, 190, 190),
                 font_color=(40, 40, 40),
                 font_size=20):
        super(PartInfo, self).__init__(size)
        self.background_color = background_color
        self.font_color = font_color
        self.font_size = font_size
        self.font = pygame.font.Font(None, self.font_size)

        self.update()
        self.render(self)

    def update(self, current_part='Unkown', next_part='Unkown'):
        self.fill(self.background_color)
        self.__current_surf = self.font.render('Current part: {}'.format(current_part), 1, self.font_color)
        self.__next_surf = self.font.render('Next part: {}'.format(next_part), 1, self.font_color)
        self.blit(self.__current_surf, (0, 0))
        self.blit(self.__next_surf, (0, self.font_size))

    def render(self, screen, pos=(0, 0)):
        screen.blit(self, pos)


class Utterances:
    def __init__(self, size=(400, 400), background_color=(227, 227, 227), font_color=(155, 155, 0)):
        self.width, self.height = size
        self.background_color = background_color
        self.font_color = font_color
        self.text_surface = pygame.Surface(size)
        self.text_surface.fill(background_color)
        self.font = pygame.font.Font(None, 25)
        self.cat_surface = pygame.Surface((self.width/2, self.height))
        self.cat_surface.fill(background_color)

        text_output_surf = self.font.render('No Interpretation Received', 1, font_color)
        self.text_surface.blit(text_output_surf, (0, 0))
        self.text_positions = OrderedDict()

    def _position_text_display(self, text_surface, cat_surface):
        new_height = text_surface.get_rect().height
        to_remove = []
        for surfaces in self.text_positions:
            self.text_positions[surfaces] += new_height
            if self.text_positions[surfaces] > self.height:
                to_remove.append(surfaces)

        self.text_positions[(text_surface, cat_surface)] = 0

        # remove surfaces outside of drawing area
        [self.text_positions.pop(surfaces) for surfaces in to_remove]

        # blit
        self.text_surface.fill(self.background_color)
        self.cat_surface.fill(self.background_color)

        for (text, cat), y_pos in self.text_positions.items():
            self.text_surface.blit(text, (0, y_pos))
            self.cat_surface.blit(cat, (0, y_pos))

    def update(self, data):
        text_output_surf = linebreak(data['text'], self.font_color, self.text_surface.get_rect(), self.font, 1)
        cat_output_surf = linebreak(data['cat'], self.font_color, self.cat_surface.get_rect(), self.font, 1)
        self._position_text_display(text_output_surf, cat_output_surf)

    def render(self, screen, pos=(0, 0)):
        screen.blit(self.text_surface, pos)
        screen.blit(self.cat_surface, (pos[0] + self.width, pos[1]))
