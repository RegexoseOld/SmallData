from os import sys, path
# sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
import pygame

def linebreak(surface, text, color, rect, font, aa=False, bkg=None):
    # aa = antialiased bkg= background color
    # print('text: {}\ncolor  {}\nrect: {}'.format(text, color, rect))
    surface.fill((22, 155, 227))
    y = rect.top
    line_spacing = -2

    #get height of font
    fontHeight = font.size("Tg")[1]

    while text:
        i = 1 # index of characters
        # determine if row of text will be outside area
        if y + fontHeight > rect.bottom:
            break
        # determine max width of line
        while font.size(text[:i])[0] < rect.width and i < len(text) +1:
            #print('font.size(text[:i])[0]:   ', font.size(text[:i])[0])
            #print('text[:i]', text[:i])
            #print('i', i)
            i += 1

        # if text is wrapped then adjust the wrap to the last word
        if i < len(text):
            #print('i: {} len(text): {}'.format(i, len(text)))
            i = text.rfind(" ", 0, i)

        # render the line and blit on surface
        if bkg:
            image = font.render(text[:i], 1, color, bkg)
            image.set_colorkey(bkg)
        else:
            image = font.render('{}'.format(text[:i]), aa, color)
        y += fontHeight + line_spacing

        surface.blit(image, (rect.left, y))

        #remove text (line) we just blitted
        text = text[i:] # the remaining text

    return surface