from surfaces import *
import pickle


add_library('oscP5') 
addr = "?"

AREAS = {}

def alert_update():
    alert = AREAS['alert']
    utt_alert = AREAS['utterances'].alert
    cat = utt_alert.keys()[0]
    alert.updateSurface(cat, alert.circle_centers[cat][0] + width * 6/13, alert.circle_centers[cat][1], utt_alert[cat][2], utt_alert[cat][3])

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
            print("\tINCOMING")
            AREAS['utterances'].update_utts(content["text"], content["cat"])
            AREAS['category_counter'].update(content['category_counter'], content["is_locked"])
            alert_update()
                
        elif m.checkAddrPattern("/display_partinfo") == True:
            targets = pickle.loads(m.arguments()[0])
            print("targets: ", targets)
            AREAS['category_counter'].update_targets(targets)
            
        elif m.checkAddrPattern("/display_init") == True:
            categories = pickle.loads(m.arguments()[0])
            AREAS['category_counter'].init_categories(categories)
            AREAS["alert"].build_circle_centers(AREAS["category_counter"].directions)

def setup():
    size(1200, 850)
    background(200)
    global font, font_bold
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
    global font
    y_spacing = height/100
    x_spacing = width/50
    AREAS["utterances"] = UtterancesArea("utterances", width/100, y_spacing, width *6/13, height *9/10, font, font_bold)
    AREAS["part_info"] = PartArea("part_info", width *6/13 - x_spacing, height *7/8 - y_spacing, width/8, height/8, font)
    AREAS["category_counter"] = CategoryStar("category_counter", width *6/13 + x_spacing, y_spacing, width/2, height * 9/10)
    AREAS["alert"] = Alert("alert", width *3/13 - x_spacing, height *2/8 - y_spacing, width/8, height/8)
    return AREAS

def stop():
    global osc
    osc.dispose()
    
