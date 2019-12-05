import pygame


def linebreak(text, color, rect, font, aa=False):
    # aa = anti-aliased bkg= background color
    y = rect.top
    line_spacing = 5

    # get height of font
    font_height = font.size("Tg")[1]
    initial_surface = pygame.Surface((rect.width - 3, rect.height - 3))
    initial_surface.fill((227, 227, 227))

    while text:
        i = 1  # index of characters
        # determine if row of text will be outside area
        if y + font_height > rect.bottom:
            print('font too big. y + font_height = ', y + font_height)
            break
        # determine max width of line
        while font.size(text[:i])[0] < rect.width and i < len(text) + 1:
            i += 1

        # if text is wrapped then adjust the wrap to the last word
        if i < len(text):
            i = text.rfind(" ", 0, i)

        # render the line and blit on surface
        image = font.render('{}'.format(text[:i]), aa, color)

        initial_surface.blit(image, (rect.left, y))
        y += font_height + line_spacing

        # remove text (line) we just blitted
        text = text[(i+1):]  # the remaining text (i+1 skips " ")

    # create another surface with the height of the text
    surface = pygame.Surface((rect.width, y))
    surface.fill((0, 0, 0))
    surface.fill((227, 227, 227), (surface.get_rect().inflate(-3, -3)))
    surface.blit(initial_surface, (1, 1))
    return surface
