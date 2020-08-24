from surfaces import *
import pickle


add_library('oscP5') 
addr = "?"

AREAS = {}

def alert_update(cat):
    global utt_width, a
    #alert = AREAS['alert']
    utt = AREAS['utterances']
    counter = AREAS['category_counter']
    alert.updateCirclefeed(cat, utt)
    alert.updateNotify(cat, counter)

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
            content = pickle.loads(m.arguments()[0])
            print("\tINCOMING :", content["cat"])
            AREAS['utterances'].update_utts(content["text"], content["cat"])
            AREAS['category_counter'].update(content['category_counter'], content["is_locked"])
            #alert_update(content["cat"])
        elif m.checkAddrPattern("/display_partinfo") == True:
            targets = pickle.loads(m.arguments()[0])
            print("targets: ", targets)
            AREAS['category_counter'].update_targets(targets)
            
        elif m.checkAddrPattern("/display_init") == True:
            categories = pickle.loads(m.arguments()[0])
            AREAS['category_counter'].init_categories(categories)
            #AREAS["alert"].build_circle_centers(AREAS["category_counter"].directions)

def setup():
    size(1200, 850)
    background(200)
    global font, font_bold, utt_width
    utt_width = width * 6/13

    font_size = 14
    font = createFont( "Helvetica", font_size, True)
    font_bold = createFont("Helvetica-Bold", font_size, True)
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
    global font, utt_width
    y_spacing = height/100
    x_spacing = width/50

    AREAS["utterances"] = UtterancesArea("utterances", width/100, y_spacing, utt_width, height *9/10, font, font_bold)
    AREAS["category_counter"] = CategoryStar("category_counter", utt_width + x_spacing, y_spacing, width/2, height * 9/10)
    AREAS["part_info"] = PartArea("part_info", width /2 - x_spacing, height /2 - y_spacing, width/8, height/8, font)
    # AREAS["alert"] = Alert("alert", width *3/5, height/3,  width/4, height/4, font)
    return AREAS

def stop():
    global osc
    osc.dispose()
    
