from surfaces import *
import pickle

import sys
import os
sys.path.append(os.path.abspath('../../../'))
import config
from song import song_machine

add_library('oscP5') 
addr = "?"

AREAS = {}

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
            info2display = pickle.loads(m.arguments()[0])
            
            utterance = info2display["text"]
            category = info2display["cat"]
            
            AREAS['utterances'].update_utts(utterance, category)
            AREAS['category_counter'].update(info2display['category_counter'], info2display["is_locked"])
        elif m.checkAddrPattern("/display_partinfo") == True:
            targets = pickle.loads(m.arguments()[0])
            AREAS['category_counter'].update_targets(targets)

def setup():
    size(1200, 850)
    background(200)
    global font
    font_size = 14
    font = createFont( "Helvetica Neue", font_size, True)
    global osc, loc
    AREAS = build_areas()
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    global listener
    listener = Listen()
    osc.addListener(listener) # assigning a listener to class Listen
    
def draw():
    for area in AREAS.values():
        area.draw()

def build_areas():
    global font
    y_spacing = height/100
    x_spacing = width/100
    AREAS["utterances"] = UtterancesArea("utterances", width/100, height/2 + y_spacing, width*8/13, height*7/16, font)
    AREAS["part_info"] = PartArea("part_info", width *2/3, height/2 + y_spacing, width *4/13, height *7/16, font)
    
    parser = song_machine.create_parser(config.settings.song_path)
    AREAS["category_counter"] = CategoryStar(parser, "category_counter", 100, 20, 400, 400)
    return AREAS

def stop():
    global osc
    osc.dispose()
    
