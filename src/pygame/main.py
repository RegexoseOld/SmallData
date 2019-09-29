import sys
import pygame
import json
sys.path.append('/Users/borisjoens/Dropbox/Kommentare/SmallData')
from status_display import SCREEN_HEIGHT, SCREEN_WIDTH, SongStatus
from playhead import Playhead

SONG_PATH = '../../config/heavy_lemon.json'
with open(SONG_PATH, 'r') as f:
    json_data = json.load(f)

playhead = Playhead()
song = SongStatus('heavy_lemon', json_data['states'], playhead)
playhead.song_parts = song.song_parts


def main():
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption('Status Screen')
    pygame.mouse.set_visible(1)
    pygame.key.set_repeat(1, 30)

    clock = pygame.time.Clock()
    running = True

    while running:
        clock.tick(30)
        screen.fill((245, 247, 246))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.event.post(pygame.event.Event(pygame.QUIT))
                song.handle_input(event.key)

        song.render(screen)
        pygame.display.flip()


if __name__ == "__main__":
    main()