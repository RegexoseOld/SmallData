import pygame

def main():
    pygame.init()
    screen_status = pygame.display.set_mode((800, 600))
    pygame.display.set_caption('Status Screen')
    pygame.mouse.set_visible(1)
    pygame.key.set_repeat(1, 30)

    clock = pygame.time.Clock()

    running = True

    while running:
        clock.tick(30)
        screen_status.fill((245, 247, 246))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            if event.type == pygame.KEYDOWN:

                if event.key == pygame.K_ESCAPE:
                    pygame.event.post(pygame.event.Event(pygame.QUIT))

    pygame.display.flip()


if __name__ == "__main__":
    main()