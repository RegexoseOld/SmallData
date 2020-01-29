from surfaces import *
import getpass
# from surfaces import Area, build_areas, sub_surfaces, AREAS

add_library('oscP5') 
addr = "?"

# Arial14 = loadFont("Arial-BoldMT-14.vlw")
current_part_name = "Unknown"
next_part_name =  "Unknown too"
current_beat = "1"
beat_color = color(255, 0 , 0)
part_dict = {}

class Listen(OscEventListener):
    def oscEvent(self, m):
        global addr, font, beat_color
        addr = m.arguments()[0]
        self.select_action(addr, m.arguments()[1:])
        print("the OscMessage ", m)
        
    def select_action(self, addr, arguments):
        print("addr !!", addr)
        global part_dict
        if addr == "/parts":
           
            part_dict[arguments[0]] = []
            print(part_dict)
        

def setup():
    size(1500, 1000)
    global font, font_size
    font_size = 14
    font = createFont("Arial-BoldMT", font_size, True)
    global osc, loc, addr
    global surface, sub_surface
    global current_part_name, next_part_name, current_beat
    global beat_color
    global part_dict
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
