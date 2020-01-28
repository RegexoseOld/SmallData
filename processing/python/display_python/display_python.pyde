add_library('oscP5') 
addr = "?"

AREA_NAMES = ["song", "utterances", "blocks", "part_info"]
AREAS = {}

class Listen(OscEventListener):
    def oscEvent(self,m):
        global col, addr
        col = m.arguments()[0]
        # col = int(m.arguments()[0])
        addr = m.addrPattern()
        print("Listen.oscEvent",m.addrPattern(), m.arguments())

class Area:
    def __init__(self, tempName, surface, pos_x, pos_y):
        self.name = tempName
        self.surface = surface
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.fill_surface(222)
    
    def fill_surface(self, color):
        with self.surface.beginDraw():
            self.surface.background(color) 

def build_surfaces(spacing_x, spacing_y): 
    pos_y1 = pos_y2 = height/16
    for i in range(len(AREA_NAMES)):
        print("pos_y: ", pos_y1)
        if i <= 1:
            surface_width = width*7/12
            surface_height = height*3/8
            pos_x = width*2/3 
            surface = createGraphics(surface_width, surface_height )
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x - surface_width - (spacing_x/2) , pos_y1)
            pos_y1 += surface_height + spacing_y
        else:
            
            surface_width = width*3/12
            surface_height = height*3/8
            pos_x = width*2/3 
            pos_y = 0
            surface = createGraphics(surface_width, surface_height )
            AREAS[AREA_NAMES[i]] = Area(AREA_NAMES[i], surface, pos_x + (spacing_x/2), pos_y2)
            pos_y2 += surface_height + spacing_y
        
    return  AREAS

def setup():
    size(1500, 1000)
    AREAS = build_surfaces(width/32, height/32)
    global osc, loc, col, surface, name
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    osc.addListener(Listen()) # assigning a listener to class Listen

def draw():
    for area in AREAS:
        surface = AREAS[area].surface
        image(surface, AREAS[area].pos_x, AREAS[area].pos_y)
