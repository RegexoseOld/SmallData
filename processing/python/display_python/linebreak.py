
def linebreak(s_width, s_height, break_text, font, font_size, bg_color):
    y = 0
    char_index = 0
    scalar = 0.8
    line_spacing = 8
    if  bg_color == None:
        bg_color = (0,0)

    # get height of font
    textSize(font_size)
    font_height = textAscent() * scalar
    temp_surface = createGraphics(s_width, s_height)

    while break_text:
        i = 1  # index of characters
        # determine if row of text will be outside area
        if y + font_height > s_height:
            print('font too big. y + font_height = ', y + font_height)
            break
        # determine max width of line
        while textWidth(break_text[:i]) < s_width and i < len(break_text) + 1:
            i += 1

        # if text is wrapped then adjust the wrap to the last word
        if i < len(break_text):
            i = break_text.rfind(" ", 0, i)

        # render the line and put on surface
        with temp_surface.beginDraw():
            temp_surface.textFont(font)
            temp_surface.textSize(font_size)
            temp_surface.textAlign(LEFT, TOP)
            temp_surface.fill(0)
            temp_surface.text(break_text[:i], 0, y)

        y += font_height + line_spacing

        # remove text (line) we just blitted
        break_text = break_text[(i+1):]  # the remaining text (i+1 skips " ")

    # create another surface with the height of the text
    new_surface = createGraphics(s_width, int(y)+ 10)
    with new_surface.beginDraw():
        new_surface.background(*bg_color)
        new_surface.image(temp_surface, 0, 0)
    return new_surface
