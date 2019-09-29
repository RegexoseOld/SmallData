import sys
import pygame
sys.path.append('/Users/borisjoens/Dropbox/Kommentare/SmallData')
from animation import Animation

SCREEN_HEIGHT = 1000
SCREEN_WIDTH = 1200
STATUS_WIDTH = SCREEN_WIDTH/2 - 25
SONG_WIDTH = STATUS_WIDTH - 15
INITIAL_POS_X = 2
INITIAL_POS_Y = 0


def create_mock_length(states):
    mock_length = {}
    for state in states:
        if state == '3':
            mock_length[state] = 8
        else:
            mock_length[state] = 4
    return mock_length


class SongStatus:
    # includes surface, song representation
    # and information fields about effects

    def __init__(self, name, parts, playhead):
        self.name = name
        self.parts = create_mock_length(parts)
        self.status_surface = pygame.Surface((STATUS_WIDTH, SCREEN_HEIGHT))
        self.song_surface = pygame.Surface((STATUS_WIDTH, SCREEN_HEIGHT / 2))
        self.song_surface.fill((204, 204, 204))
        self.song = pygame.Surface((SONG_WIDTH, SCREEN_HEIGHT / 3))
        self.song.set_colorkey((0, 0, 0))
        self.build_song(self.parts)
        self.playhead = playhead
        self.song_surface.blit(self.song, (20, 5))
        self.status_surface.fill((214, 32, 32))

    def render(self, screen):
        screen.blit(self.song_surface, (0, 0) )
        self.playhead.render(screen)

    def handle_input(self, data):
        self.playhead.handle_input(data)

    def build_song(self, parts):
        pos = INITIAL_POS_X
        for length in parts.values():
            part_length = (SONG_WIDTH / (len(parts) * 5)) * length
            pygame.draw.rect(self.song, (117, 117, 117),
                             (pos, 0, part_length, SCREEN_HEIGHT/4), 2)
            pos += part_length

class Playhead:
    def __init__(self):
        self.playhead_surface = pygame.Surface((SONG_WIDTH / 8, SCREEN_HEIGHT / 4))
        self.playhead_surface.set_colorkey((0, 0, 0))
        self.playhead = self.create_playhead(self.playhead_surface.get_size())
        self.anim_left = Animation(self.playhead_surface, 0, 0, 2, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(), 3)
        self.anim_right = Animation(self.playhead_surface, 0, 0, 2, self.playhead_surface.get_width(), \
                                                              self.playhead_surface.get_height(),3)
        self.dir = 0
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
        if self.dir == -1:
            if self.playing:
                # only update then
                self.anim_left.update()
            self.anim_left.render(screen, (self.pos_x, self.pos_y))
        else:
            if self.playing:
                # only update then
                self.anim_right.update()
            self.anim_right.render(screen, (self.pos_x, self.pos_y))
        self.playing = False

    def handle_input(self, key):
        if key == pygame.K_RIGHT:
            self.pos_x += 1
            self.dir = 1
            self.playing = True
        elif key == pygame.K_LEFT:
            self.pos_x -= 1
            self.dir = -1
            self.playing = True
