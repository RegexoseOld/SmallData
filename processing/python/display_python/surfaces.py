from collections import OrderedDict
from linebreak import linebreak

AREA_NAMES = ["song", "utterances", "blocks", "part_info"]
AREAS = {}
UTTERANCE_DICT = OrderedDict()

class Area:
    def __init__(self, tempName, surface, pos_x, pos_y):
        self.name = tempName
        self.surface = surface
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = {}
        self.fill_surface(222)
    
    def fill_surface(self, col):
        if not self.name == "utterances":
            with self.surface.beginDraw():
                self.surface.background(col) 
        # print("filled {} with {}".format(self.name, col))
      
    def update_subsurfaces(self, name, surface):
        # print("subdate: {} with {}".format(self.name, name))
        for value in list(self.subsurfaces.values()):
            surf = value.surface
            if name == value.name:
                surf = surface
    
    def update_utterances(self, utt, cat, max_utts=5):
        for surf in self.subsurfaces.values():
            if surf.name == "utts":
                surf = surf.update_utts(utt, max_utts)
                self.update_subsurfaces("utts", surf)
            else:
                surf = surf.update_utts(cat, max_utts)
                self.update_subsurfaces("cats", surf)

               
            
class Subsurface:
    index = 1
    def __init__(self, name, parent_surface, x_div, y_div, x_pos, y_pos, font):
        self.name = name
        self.parent = parent_surface
        self.x_div = x_div
        self.y_div = y_div
        self.x_pos = x_pos
        self.y_pos = y_pos
        self.txt = ""
        self.font = font
        self.beat_color = color(0, 230, 20)
        self.utterance_dict = OrderedDict()
        self.surface = createGraphics(int(self.parent.surface.width * self.x_div), int(self.parent.surface.height * self.y_div))
        self.surface.smooth()
        self.parent.subsurfaces[self.name] = self
  
    def text_on_surface(self, surface, txt, font_size, col):
        # print("update txt: {}".format(txt))
        with surface.beginDraw():
            surface.background(222)
            surface.textFont(self.font)
            surface.textSize(font_size)
            surface.fill(col)
            surface.textAlign(CENTER)
            surface.text(txt, surface.width/2, surface.height/2)
        return surface
    
    def utts_on_surface(self, surface):
        self.surface = self.text_on_surface(self.surface, utterance, 20, color(50))
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_beat(self, beat_number, change_color):
        # print("beat {} change?  {}".format(beat_number, change_color))
        if change_color == "True":
            self.beat_color = color(250, 0, 150)
        else: 
            self.beat_color = color(10, 250, 20)
        self.txt = beat_number
        self.surface = self.text_on_surface(self.surface, self.txt, 80, self.beat_color)
        # print("beat.parent: ", self.parent.name)
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_current(self, current_part):
        self.surface = self.text_on_surface(self.surface, "current part - \n" + current_part, 20,  color(50))
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_next(self, next_part):
        self.surface = self.text_on_surface(self.surface, "next part - \n" + next_part, 20, color(50))
        self.parent.update_subsurfaces(self.name, self.surface)
    
    def update_utts(self, message, max_utts, ):
        global UTTERANCE_DICT
        temp_surface = linebreak(self.surface, message, self.font, 18)
        if self.name == "utts":
            self.utterance_dict[self.index] = [temp_surface, temp_surface.height + 5]
            UTTERANCE_DICT = self.utterance_dict
        else: 
            self.utterance_dict[self.index] = [temp_surface, UTTERANCE_DICT[self.index][1]]

        pos_y = 0
        with self.surface.beginDraw():
            self.surface.background(200)
        for value in reversed(list(self.utterance_dict.values())):
            # alle untereinander positionieren
            with self.surface.beginDraw():
                # print("\index: {}  y_pos: {} ".format(self.index, pos_y))
                self.surface.image(value[0], 0, pos_y)
            pos_y += value[1]
            
        if len(UTTERANCE_DICT) > max_utts:
            print("dict length: ", len(self.utterance_dict))
            UTTERANCE_DICT.popitem(last=False)
            self.utterance_dict.popitem(last=False)
        self.index += 1
        return self.surface
        
    def position_utt_surfaces(self, utt, cat, pos_y):
        cat_surf = self.parent.subsurfaces["cats"]
        if not pos_y >= self.surface.height:
           
            with cat_surf.beginDraw():
                cat_surf.image(cat, self.parent.subsurfaces["cats"].x_pos, y_pos)
        else:      
            return utt, cat

def build_areas(spacing_x, spacing_y): 
    pos_y1 = pos_y2 = height/16
    for i in range(len(AREA_NAMES)):
        if i <= 1:
            surface_width = width*8/13
            surface_height = height*7/16
            pos_x = width*2/3 
            surface = createGraphics(surface_width, surface_height)
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x - surface_width - (spacing_x/2) , pos_y1)
            pos_y1 += surface_height + spacing_y
        else:
            surface_width = width*4/14
            surface_height = height*7/16
            pos_x = width*2/3 
            pos_y = 0
            surface = createGraphics(surface_width, surface_height )
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x + (spacing_x/2), pos_y2)
            pos_y2 += surface_height + spacing_y
    return  AREAS   

def sub_surfaces(font):
    for name in AREAS:
        parent = AREAS[name]
        if name == "utterances":
            utt_surf = Subsurface("utts", parent, 0.66, 1, parent.pos_x, parent.pos_y, font)
            cat_surf = Subsurface("cats", parent, 0.33, 1, parent.pos_x + utt_surf.surface.width, parent.pos_y, font)
        elif name == "part_info":
            current_surf = Subsurface("current", parent, 0.5, 0.5, parent.pos_x, parent.pos_y, font)
            current_surf.txt = "current part"
            next_surf = Subsurface("next", parent, 0.5, 0.5, parent.pos_x, parent.pos_y + current_surf.surface.height, font)
            next_surf.txt = "next Part"
            beat_surf = Subsurface("beat", parent, 0.5, 1, parent.pos_x + parent.surface.width/2, parent.pos_y, font)
            beat_surf.txt = "1"
        else:
            pass
