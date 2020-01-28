
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
    
    def fill_surface(self, color):
        with self.surface.beginDraw():
            self.surface.background(color) 
    
    def update_subsurface(self, surface, pos_x, pos_y):
        # add surface to list
        self.surface.image(surface, pos_x, pos_y)

class Subsurface:
    def __init__(self, name, parent_surface):
        self.name = name
        self.parent = parent_surface
        self.surface = createGraphics(self.parent.width*7/12, self.parent.height)
        self.parent.update_subsurface(self)
        # man braucht doch Angaben zu Dimensionen s. sub_surfaces()
        

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

def sub_surfaces():
    for name in AREAS:
        parent = AREAS[name].surface
        if name == "utterances":
            sub_surf = Subsurface("utts", parent)
        
