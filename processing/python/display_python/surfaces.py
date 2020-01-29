AREA_NAMES = ["song", "utterances", "blocks", "part_info"]
AREAS = {}
SUBSURFACE_NAMES = ["utts", "cats", "current_part", "next_part", "beat"]


class Area:
    def __init__(self, tempName, surface, pos_x, pos_y):
        self.name = tempName
        self.surface = surface
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = []
        self.fill_surface(222)
    
    def fill_surface(self, col):
        with self.surface.beginDraw():
            self.surface.background(col) 
        # print("filled {} with {}".format(self.name, col))
      
    def update_sub(self, font, font_size, col):
        if len(self.subsurfaces) != 0:
            # print("updating ...  ", self.name)
            ss_dict = {}
            for ss in self.subsurfaces:
                # print("updating   ", ss.name)
                with ss.surface.beginDraw():
                    ss.surface.background(111)
                    ss.surface.textFont(font)
                    ss.surface.textSize(20)
                    ss.surface.textAlign(CENTER)
                    ss.surface.fill(200)
                    ss.surface.text("dong", ss.surface.width/2, ss.surface.height/2)
                ss_dict[ss.surface] = [ss.x_pos, ss.y_pos]
            return ss_dict
                
        else:
            return {self.surface: [self.pos_x, self.pos_y]}
            
class Subsurface:
    def __init__(self, name, parent_surface, x_div, y_div, x_pos, y_pos):
        self.name = name
        self.parent = parent_surface
        self.x_div = x_div
        self.y_div = y_div
        self.x_pos = x_pos
        self.y_pos = y_pos
        self.txt = ""
        self.surface = createGraphics(int(self.parent.surface.width * self.x_div), int(self.parent.surface.height * self.y_div))
        self.parent.subsurfaces.append(self)
    
    def add_text(self, txt, font, col):
        self.txt = txt
        with self.surface.beginDraw():
            self.surface.textFont(font)
            self.surface.fill(col)
            self.surface.textAlign(CENTER)
            self.surface.text("next part is: " + self.txt, self.surface.width/2, self.surface.height/2)

        

def build_areas(spacing_x, spacing_y): 
    pos_y1 = pos_y2 = height/16
    for i in range(len(AREA_NAMES)):
        print("pos_y: ", pos_y1)
        if i <= 1:
            surface_width = width*8/13
            surface_height = height*7/16
            pos_x = width*2/3 
            surface = createGraphics(surface_width, surface_height )
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
            sub_surf1 = Subsurface("utts", parent, 0.66, 1, parent.pos_x, parent.pos_y)
            sub_surf2 = Subsurface("cats", parent, 0.33, 1, parent.pos_x + sub_surf1.surface.width, parent.pos_y)
        elif name == "part_info":
            current_surf = Subsurface("current", parent, 0.5, 0.5, parent.pos_x, parent.pos_y)
            current_surf.add_text("Unknown", font, color(20))
            next_surf = Subsurface("next", parent, 0.5, 0.5, parent.pos_x, parent.pos_y + current_surf.surface.height)
            next_surf.add_text("not known either", font, color(20))
            beat_surf = Subsurface("beat", parent, 0.5, 1, parent.pos_x + parent.surface.width/2, parent.pos_y)
            beat_surf.add_text("beat: ", font, color(255, 0 , 0))
        else:
            pass
