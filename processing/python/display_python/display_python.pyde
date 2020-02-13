from surfaces import *
import getpass

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
            AREAS['part_info'].update_parts(current_part_name, next_part_name, current_beat, change_color)
        elif m.checkAddrPattern("/display_input") == True:
            utterance = "".join([str(i) for i in list(m.arguments()[0])])
            category = "".join([str(i) for i in list(m.arguments()[1])])
            AREAS['utterances'].update_utts(utterance, category)

def setup():
    size(1200, 850)
    background(200)
    # global font, font_size
    font_size = 14
    font = createFont( "Helvetica Neue", font_size, True)
    global osc, loc
    AREAS = build_areas(font2)
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    global listener
    listener = Listen()
    osc.addListener(listener) # assigning a listener to class Listen
    
def draw():
    for area in AREAS.values():
        area.draw()
        
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
    
