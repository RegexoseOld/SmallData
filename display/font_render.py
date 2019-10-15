from os import sys, path
# sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
import pygame

def linebreak(text, color, rect, font, aa=False, bkg=None):
    # aa = antialiased bkg= background color
    # print('text: {}\ncolor  {}\nrect: {}'.format(text, color, rect))
    y = rect.top
    line_spacing = -2

    #get height of font
    fontHeight = font.size("Tg")[1]
    # print('surface height: ', surface_height)
    initial_surface = pygame.Surface((rect.width, rect.height))
    initial_surface.fill((227, 227, 227))


    while text:
        i = 1 # index of characters
        # determine if row of text will be outside area
        if y + fontHeight > rect.bottom:
            print('font too big. y + fontHeight = ', y + fontHeight)
            break
        # determine max width of line
        while font.size(text[:i])[0] < rect.width and i < len(text) + 1:
            i += 1

        # if text is wrapped then adjust the wrap to the last word
        if i < len(text):
            i = text.rfind(" ", 0, i)

        # render the line and blit on surface
        if bkg:
            image = font.render(text[:i], 0, color, bkg)
            image.set_colorkey(bkg)
        else:
            image = font.render('{}'.format(text[:i]), aa, color)

        initial_surface.blit(image, (rect.left, y))
        y += fontHeight + line_spacing

        #remove text (line) we just blitted
        text = text[(i+1):] # the remaining text (i+1 skips " ")

    # create another surface with the height of the text
    surface = pygame.Surface((rect.width, y))
    surface.blit(initial_surface, (0, 0))
    return surface