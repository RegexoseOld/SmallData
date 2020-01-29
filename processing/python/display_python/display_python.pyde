from surfaces import *
# from surfaces import Area, build_areas, sub_surfaces, AREAS


add_library('oscP5') 
addr = "?"

# Arial14 = loadFont("Arial-BoldMT-14.vlw")
current_part_name = "Unknown"
next_part_name =  "Unknown too"
current_beat = "1"
beat_color = color(255, 0 , 0)

class Listen(OscEventListener):
    def oscEvent(self, m):
        global col, addr, font
        col = m.arguments()[0]
        # col = int(m.arguments()[0])
        addr = m.addrPattern()
        print("Listen.oscEvent",m.addrPattern(), m.arguments())

def setup():
    size(1500, 1000)
    global font, font_size
    font_size = 14
    font = createFont("Arial-BoldMT", font_size, True)
    global osc, loc, col
    global surface, sub_surface
    global current_part_name, next_part_name, current_beat
    global beat_color
    AREAS = build_areas(width/40, height/36)
    sub_surfaces(font)
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    osc.addListener(Listen()) # assigning a listener to class Listen
    
def draw():
    global font_size, beat_color
    for a in AREAS:
        area = AREAS[a]
        if mousePressed:
            font_size = 25
            beat_color = color(0, 255, 0)
        else:
            font_size = 14
            beat_color = color(0, 0, 255)
        surface_dict = area.update_sub(font, font_size, beat_color)
        # print("subsurf: {}, x: {}  y: {}".format(subsurf.width, x, y))
        image(area.surface, area.pos_x, area.pos_y)
        for surf, pos in surface_dict.items():
            image(surf, pos[0], pos[1])
