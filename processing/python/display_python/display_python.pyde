from surfaces import Area, build_areas, AREAS

add_library('oscP5') 
addr = "?"

class Listen(OscEventListener):
    def oscEvent(self,m):
        global col, addr
        col = m.arguments()[0]
        # col = int(m.arguments()[0])
        addr = m.addrPattern()
        print("Listen.oscEvent",m.addrPattern(), m.arguments())

def setup():
    size(1500, 1000)
    AREAS = build_areas(width/40, height/36)
    global osc, loc, col
    global surface, sub_surface
    osc = OscP5(this, 5040)
    loc = NetAddress('127.0.0.1', 5040) # send to self
    osc.addListener(Listen()) # assigning a listener to class Listen
    
def draw():
    for area in AREAS:
        surface = AREAS[area].surface
        image(surface, AREAS[area].pos_x, AREAS[area].pos_y)
