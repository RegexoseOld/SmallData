import sys
import pygame
sys.path.append('/Users/borisjoens/Dropbox/Kommentare/SmallData')
# import statements must change if imported from song/song_server.py
from display.animation import Animation
from display.status_display import SCREEN_HEIGHT, SONG_WIDTH


class Playhead:
    def __init__(self):
        self.playhead_surface = pygame.Surface((SONG_WIDTH / 8, SCREEN_HEIGHT / 4))
        self.playhead_surface.set_colorkey((0, 0, 0))
        self.playhead = self.create_playhead(self.playhead_surface.get_size())
        self.anim_part_begin = Animation(self.playhead_surface, 0, 0, 1, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(), 1)
        self.anim_right = Animation(self.playhead_surface, 0, 0, 1, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(),1)
        self.song_parts = {} # will be populated in SongStatus
        self.current_part = 'intro'
        # initial position for playhead
        self.pos_x = float(self.song_parts['intro'][0])
        self.pos_y = float(self.playhead_surface.get_height() + 5)
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
        # part loopen
        if self.pos_x == self.song_parts[self.current_part][1]:
            if self.playing:
                # only update then
                self.anim_part_begin.update()
            self.pos_x = self.song_parts[self.current_part][0]
            self.anim_part_begin.render(screen, (self.pos_x, self.pos_y))
        # zu part springen
        else:
            if self.playing:
                # only update then
                self.anim_right.update()
            self.anim_right.render(screen, (self.pos_x, self.pos_y))
        self.playing = False

    def handle_input_key(self, key):
        if key == pygame.K_RIGHT:
            self.pos_x += 1
            self.playing = True
        elif key == pygame.K_LEFT:
            self.pos_x -= 1
            self.dir = -1
            self.playing = True

    def handle_input_data(self, data):
        if data == 1:
            self.pos_x += 1
            self.playing = True
        else:
            print('triggered: ', data)
            self.pos_x = self.song_parts[data][0]
            # print('self-pos_x: {} self.pos_y. {}'.format(self.pos_x, self.pos_y))
            self.current_part = data
            self.playing = True
