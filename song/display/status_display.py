import pygame

SCREEN_HEIGHT = 1000
SCREEN_WIDTH = 1200
STATUS_WIDTH = SCREEN_WIDTH/2 - 25
SONG_WIDTH = STATUS_WIDTH - 15
INITIAL_POS_X = 2
INITIAL_POS_Y = 0


def create_mock_length(states):
    mock_length = {}
    for state in states:
        if state == 'part1':
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
        self.song_surface.set_colorkey((204, 204, 204))
        self.song = pygame.Surface((SONG_WIDTH, SCREEN_HEIGHT / 3))
        self.song.set_colorkey((0, 0, 0))
        self.song_parts = {}
        self.build_song(self.parts)
        self.playhead = playhead
        self.playhead.song_parts = self.song_parts
        self.song_surface.blit(self.song, (20, 5))
        self.status_surface.fill((214, 32, 32))

    def render(self, screen):
        screen.blit(self.song_surface, (0, 0))
        self.playhead.render(screen)

    def handle_input(self, data):
        self.playhead.handle_input_key(data)

    def build_song(self, parts):
        pos = INITIAL_POS_X
        for part, length in list(parts.items()):
            part_length = (SONG_WIDTH / (len(parts) * 5)) * length
            pygame.draw.rect(self.song, (117, 117, 117),
                             (pos, 0, part_length, SCREEN_HEIGHT/4), 2)
            self.song_parts[part] = [pos, pos + part_length]
            pos += part_length

