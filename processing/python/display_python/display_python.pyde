from surfaces import *
import getpass
# from surfaces import Area, build_areas, sub_surfaces, AREAS

add_library('oscP5') 
addr = "?"

class Listen(OscEventListener):
    def oscEvent(self, m):
        global loc, osc
        if m.checkAddrPattern("/beat")==True:
            current_beat = "".join([str(i) for i in list(m.arguments()[0])][0])
            change_color = "".join([str(i) for i in list(m.arguments()[1])])
            current_part_name = "".join([str(i) for i in list(m.arguments()[2])])
            next_part_name = "".join([str(i) for i in list(m.arguments()[3])])
            AREAS['part_info'].subsurfaces['beat'].update_beat(current_beat, change_color)
            AREAS['part_info'].subsurfaces['current'].update_part(current_part_name, "current part is \n")
            AREAS['part_info'].subsurfaces['next'].update_part(next_part_name, "next part is \n")
        elif m.checkAddrPattern("/display_input") == True:
            utterance = "".join([str(i) for i in list(m.arguments()[0])])
            category = "".join([str(i) for i in list(m.arguments()[1])])
            AREAS['utterances'].update_utterances(utterance, category)

        

def setup():
    size(1200, 850)
    background(200)
    global font, font2, font_size
    font_size = 14
    font = createFont("Arial-BoldMT", font_size, True)
    font2 = createFont( "Helvetica Neue", font_size, True)
    global osc, loc
    AREAS = build_areas(width/40, height/36)
    sub_surfaces(font2)
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    global listener
    listener = Listen()
    osc.addListener(listener) # assigning a listener to class Listen
    
def draw():
    for a in AREAS:
        area = AREAS[a]
        # surface_dict = area.update_sub(font, font_size, beat_color)
        # print("subsurf: {}, x: {}  y: {}".format(subsurf.width, x, y))
        image(area.surface, area.pos_x, area.pos_y)
        for value in area.subsurfaces.values():
            image(value.surface, value.x_pos, value.y_pos)

def reconnect():
    global osc, loc
    print("Net Address {} connected ?  {}".format(loc, loc.isvalid()))
    osc.disconnect(loc)
    print("Net Address {} connected ?  {}".format(loc, loc.isvalid()))
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040)

def stop():
    global osc
    osc.dispose()
    
