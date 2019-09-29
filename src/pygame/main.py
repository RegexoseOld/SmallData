import sys
import pygame
import json
import random
sys.path.append('/Users/borisjoens/Dropbox/Kommentare/SmallData')
from status_display import SCREEN_HEIGHT, SCREEN_WIDTH, SongStatus
from playhead import Playhead

SONG_PATH = '../../config/heavy_lemon.json'
with open(SONG_PATH, 'r') as f:
    json_data = json.load(f)

playhead = Playhead()
song = SongStatus('heavy_lemon', json_data['states'], playhead)
playhead.song_parts = song.song_parts
# print('playhead song parts', playhead.song_parts)
print('json', json_data['states'])

trigger = [1 for x in range(2000)]

for i in range(len(trigger)):
    random_index = random.randint(0, 2000)
    random_state = random.randint(0, 4)
    if i in [200, 500, 750, 945, 1888, 1032]:
        trigger[i] = json_data['states'][random_state]





def mock_songplay(data):
    if isinstance(data, str):
        playhead.handle_input_data(data)
    else:
        playhead.handle_input_data(1)


def main():
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption('Status Screen')
    pygame.mouse.set_visible(1)
    pygame.key.set_repeat(1, 30)

    clock = pygame.time.Clock()
    index = 0
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
        mock_songplay(trigger[index])
        index += 1
        song.render(screen)
        pygame.display.flip()


if __name__ == "__main__":
    main()