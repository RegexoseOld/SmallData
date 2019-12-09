import pygame
from collections import OrderedDict

from song.display.font_render import linebreak
from song.display.display_server import width, height, font, font_color, grey


height_textsurface = height / 2
width_text = width / 2
width_cat = width/4


class Utterances:
    def __init__(self):
        self.text_surface = pygame.Surface((width_text, height_textsurface))
        self.text_surface.fill(grey)

        self.cat_surface = pygame.Surface((width_cat, height_textsurface))
        self.cat_surface.fill(grey)

        text_output_surf = font.render('No Interpretation Received', 1, font_color)
        self.text_surface.blit(text_output_surf, (0, 0))
        self.text_positions = OrderedDict()

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

    def update(self, data):
        text_output_surf = linebreak(data['text'], font_color, self.text_surface.get_rect(), font, 1)
        cat_output_surf = linebreak(data['cat'], font_color, self.cat_surface.get_rect(), font, 1)
        self._position_text_display(text_output_surf, cat_output_surf)

    def render(self, screen, pos=(0, 0)):
        screen.blit(self.text_surface, pos)
        screen.blit(self.cat_surface, (pos[0] + width_text, pos[1]))
