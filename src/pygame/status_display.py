import pygame
from main import SCREEN_WIDTH, SCREEN_HEIGHT
import json

STATUS_WIDTH = SCREEN_WIDTH/2
QUEST_WIDTH = SCREEN_WIDTH/2
SONG_WIDTH = SCREEN_WIDTH/3

status_surface = pygame.Surface((STATUS_WIDTH, SCREEN_HEIGHT))
quest_surface = pygame.Surface((QUEST_WIDTH, SCREEN_HEIGHT))
song_surface = pygame.Surface((SONG_WIDTH, SCREEN_HEIGHT/2))
textdisplay_surface = pygame.Surface((SONG_WIDTH, SCREEN_HEIGHT/2))

status_surface.blit(song_surface, (0, 0))

path_to_song_file = '../../../config/heavy_lemon.json'
with open(path_to_song_file, 'r') as f:
    json_data = json.load(f)

def create_mock_length(states):
    mock_length = {}
    for state in states:
        mock_length[state] = 4
    return mock_length

class SongBuilder:
    def __init__(self, name, parts):
        self.name = name
        self.parts = create_mock_length(parts)
        self.build_song(self.parts)

    def build_song(self, parts):
        print(parts)

        for state, length in parts.items():
            part_length = SONG_WIDTH / len(parts)
            part = pygame.draw.rect(song_surface, (227, 227, 227), (0, 0, part_length, SCREEN_HEIGHT/10))

class SongPlayhead(object):
    '''a playhead indicating where we are at the current song'''
    def __init__(self):
        self.playhead = None
        pass

song = SongBuilder('heavy_lemon', json_data['states'])