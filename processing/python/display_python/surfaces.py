from collections import OrderedDict
from linebreak import linebreak

# AREAS = {}

class SurfaceBase:
    def __init__(self, name, pos_x, pos_y, s_width, s_height):
        self.name = name
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.subsurfaces = OrderedDict()
        self.__create_surface(s_width, s_height)
        
    def __create_surface(self, w, h):
        self.surface = createGraphics(w, h)
        self.surface.smooth()
        with self.surface.beginDraw():
            self.surface.background(222)
    
    def draw(self, surface=None):
        if surface:
            with surface.beginDraw():
                surface.image(self.surface, self.pos_x, self.pos_y)
        else:
            image(self.surface, self.pos_x, self.pos_y)
        for subsurf in self.subsurfaces.values():
            subsurf.draw(self.surface)
        
    def add_subsurface(self, name, area):
        self.subsurfaces[name] = area
        
class UtteranceLine:
    def __init__(self, s_width, s_height, utt, cat, font, pos_x):
        self.pos_x = pos_x
        self.pos_y = 0
        temp_utt_surface = linebreak(s_width * 2/3, s_height, utt, font, 17)
        temp_cat_surface = createGraphics(s_width * 1/3, temp_utt_surface.height)
        utt_cat_surface = createGraphics((temp_utt_surface.width + temp_cat_surface.width) - 10 , temp_utt_surface.height)
        with temp_cat_surface.beginDraw():
            temp_cat_surface.textFont(font)
            temp_cat_surface.textSize(17)
            temp_cat_surface.textAlign(LEFT, TOP)
            temp_cat_surface.fill(0)
            temp_cat_surface.text(cat, 0, 0)
        with utt_cat_surface.beginDraw():
            utt_cat_surface.background(222)
            utt_cat_surface.image(temp_utt_surface, 0, 0)
            utt_cat_surface.image(temp_cat_surface, temp_utt_surface.width + 10 , 0)
            utt_cat_surface.stroke(200)
            utt_cat_surface.strokeWeight(15)
            utt_cat_surface.line(0, utt_cat_surface.height, utt_cat_surface.width, utt_cat_surface.height)
            utt_cat_surface.line(temp_utt_surface.width, 0, temp_utt_surface.width, utt_cat_surface.height)
        self.surface = utt_cat_surface
        
    def set_pos_y(self, pos):
        self.pos_y = pos
    
    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, self.pos_x, self.pos_y) 

class UtterancesArea(SurfaceBase):
    def __init__(self, name, pos_x, pos_y, s_width, s_height, font):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.index = 0
        self.font = font
    
    def update_utts(self, utt, cat):
        utt_cat_surf = UtteranceLine(self.surface.width, self.surface.height, utt, cat, self.font, self.pos_x)
        self.add_subsurface(self.index, utt_cat_surf)
        self.index += 1
               
        pos_y = 0
        self.iterate = True
        surfaces_to_iterate = reversed(list(self.subsurfaces.values()))
        for utt_line in surfaces_to_iterate:
            utt_line.set_pos_y(pos_y)
            if pos_y >= self.surface.height:
                break 
            pos_y += utt_line.surface.height
    
        if pos_y > self.surface.height:
            self.subsurfaces.popitem(last=False)  
             
class Beat:
    def __init__(self, s_width, s_height, beatnum, col, font):
        self.surface = createGraphics(s_width, s_height)
        self.update_beatnum(beatnum, font, col)
    
    def update_beatnum(self, beatnum, font, col):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.surface.textFont(font)
            self.surface.textSize(100)
            self.surface.fill(col)
            self.surface.textAlign(CENTER)
            self.surface.text(beatnum, self.surface.width/2, self.surface.height * 3/5)
        
    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, self.surface.width *4/5, 0) 
    
class Parts:
    def __init__(self, s_width, s_height, current, next, font, col):
        self.surface = createGraphics(s_width, s_height)
        self.update_parts(current, next, font, col)
    
    def update_parts(self, current, next, font, col):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.surface.textFont(font)
            self.surface.textSize(20)
            self.surface.fill(0)
            self.surface.textAlign(CENTER)
            self.surface.text("current part:\n" + current, self.surface.width/2, self.surface.height/4)
            self.surface.text("next part:\n" + next, self.surface.width/2, self.surface.height*3/4)
    
    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, 0, 0) 
    
    
class PartArea(SurfaceBase):
    def __init__(self, name, pos_x, pos_y, s_width, s_height, font):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.font = font
    
    def update_parts(self, current, next, beatnum, change):
        if change == "True":
            col = color(250, 0, 20)
        else: 
            col = color(10, 250, 0)
        beat_surf = Beat(self.surface.width/2, self.surface.height, beatnum, col, self.font)
        current_next_surf = Parts(self.surface.width/2, self.surface.height, current, next, self.font, col)
        self.add_subsurface("beat", beat_surf)
        self.add_subsurface("parts", current_next_surf)
        

class CategoryCounter(SurfaceBase):
    bar_width = 100
    bar_distance = 5
    height_per_count = 5
    max_count = 10
    x_offset = 5
    text_height = 20
    
    categories = ['praise', 'dissence', 'insinuation', 'lecture', 'concession']
    
    def __init__(self, name, pos_x, pos_y, font):
        self.font = font
        s_width = self.bar_width * len(self.categories) + self.bar_distance * (len(self.categories)-1) + 2* self.x_offset
        s_height = self.height_per_count * self.max_count + self.text_height
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.reset_counter()
    
    def reset_counter(self):
        self.update_counter({}.fromkeys(self.categories, 0))
        
    def add_locked(self):
        with self.surface.beginDraw():
            self.surface.text("Locked", 20, 20)
    
    def update_counter(self, category_counter):
        idx = 0
        with self.surface.beginDraw():
            self.surface.background(222)
            for cat, count in category_counter.items():
                self.surface.rect(self.x_offset + idx * (self.bar_width + self.bar_distance), 
                                  self.max_count*self.height_per_count, 
                                  self.bar_width, 
                                  -count*self.height_per_count)
                self.surface.text(cat, self.x_offset + idx * (self.bar_width + self.bar_distance), self.height_per_count * self.max_count + self.text_height/2.)
                idx += 1
