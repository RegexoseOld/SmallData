import sys
import pygame
sys.path.append('/Users/borisjoens/Dropbox/Kommentare/SmallData')
from animation import Animation
from status_display import SCREEN_HEIGHT, SONG_WIDTH, INITIAL_POS_X


class Playhead:
    def __init__(self):
        self.playhead_surface = pygame.Surface((SONG_WIDTH / 8, SCREEN_HEIGHT / 4))
        self.playhead_surface.set_colorkey((0, 0, 0))
        self.playhead = self.create_playhead(self.playhead_surface.get_size())
        self.anim_part_begin = Animation(self.playhead_surface, 0, 0, 2, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(), 3)
        self.anim_right = Animation(self.playhead_surface, 0, 0, 2, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(),3)
        self.dir = 0
        self.song_parts = {'0' : 2, '1': 500}
        #  initial position for playhead
        self.pos_x = INITIAL_POS_X - 4
        self.pos_y = self.playhead_surface.get_height() + 5
        self.playing = False

    def create_playhead(self, size):
        pointer = [(25, 2), (35, 20), (27, 20), (27, 60), (23, 60), (23, 20), (15, 20)]
        # recalculate edges
        for t in pointer:
            t = list(t)
            t[0] = size[0] / t[0]
            t[1] = size[1] / t[1]
        playhead = pygame.draw.polygon(self.playhead_surface, (117, 117, 117), pointer, 0)
        return playhead

    def render(self, screen):
        if self.pos_x == int(self.song_parts['bridge']):
            if self.playing:
                # only update then
                self.anim_part_begin.update()
            self.pos_x = self.song_parts['intro']
            self.anim_part_begin.render(screen, (self.pos_x, self.pos_y))
        else:
            if self.playing:
                # only update then
                self.anim_right.update()
            self.anim_right.render(screen, (self.pos_x, self.pos_y))
        self.playing = False

    def handle_input_key(self, key):
        if key == pygame.K_RIGHT:
            self.pos_x += 1
            self.dir = 1
            self.playing = True
        elif key == pygame.K_LEFT:
            self.pos_x -= 1
            self.dir = -1
            self.playing = True

    def handle_input_data(self, data):
        if data == 1:
            self.pos_x += 1
            self.dir = 1
            self.playing = True
        elif data == pygame.K_LEFT:
            self.pos_x -= 1
            self.dir = -1
            self.playing = True
