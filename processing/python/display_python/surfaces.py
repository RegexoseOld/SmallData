from collections import OrderedDict
from linebreak import linebreak
from CircleClass import Circle
import math

color_scheme = {'dissence': (181, 180, 179),
                'insinuation': (30, 101, 109),
                'lecture': (30, 150, 109),
                'praise': (246, 41, 0),
                'concession': (241, 243, 150)
                }

class SurfaceBase:
    def __init__(self, name, pos_x, pos_y, s_width, s_height):
        self.name = name
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.s_width = s_width
        self.incoming = False  # utterance coming in
        self.subsurfaces = OrderedDict()
        self.__create_surface(s_width, s_height)
        
    def __create_surface(self, w, h):
        self.surface = createGraphics(w, h)
        self.surface.smooth()
        with self.surface.beginDraw():
            self.surface.background(222)
    
    def draw(self, surface=None):
        if surface:
            print("name if surface: {}".format(self.name))
            with surface.beginDraw():
                surface.image(self.surface, self.pos_x, self.pos_y)
        else:
            image(self.surface, self.pos_x, self.pos_y)
        for subsurf in self.subsurfaces.values():
            subsurf.draw(self.surface)
        
    def add_subsurface(self, name, area):
        self.subsurfaces[name] = area


class UtteranceLine:
    cat_surface = None
    
    def __init__(self, s_width, s_height, utt, cat, font, font_bold, pos_x):
        self.pos_x = pos_x
        self.pos_y = 0
        temp_utt_surface = linebreak(s_width * 2/3, s_height, utt, font, 17, None)
        self.cat_surface = createGraphics(s_width * 1/3, temp_utt_surface.height)
        utt_cat_surface = createGraphics((temp_utt_surface.width + self.cat_surface.width) - 10 , temp_utt_surface.height)
        cat_backgr_col = color_scheme[cat]
        with self.cat_surface.beginDraw():
            self.cat_surface.background(*cat_backgr_col)
            self.cat_surface.textFont(font_bold)
            self.cat_surface.textSize(17)
            self.cat_surface.textAlign(CENTER)
            self.cat_surface.fill(0)
            self.cat_surface.text(cat, self.cat_surface.width/2, self.cat_surface.height/2)
        with utt_cat_surface.beginDraw():
            utt_cat_surface.background(222)
            utt_cat_surface.image(temp_utt_surface, 0, 0)
            utt_cat_surface.image(self.cat_surface, temp_utt_surface.width + 10, 0)
            utt_cat_surface.stroke(200)
            utt_cat_surface.strokeWeight(15)
            utt_cat_surface.line(0, utt_cat_surface.height, utt_cat_surface.width, utt_cat_surface.height)
            utt_cat_surface.line(temp_utt_surface.width, 0, temp_utt_surface.width, utt_cat_surface.height)
        self.surface = utt_cat_surface
        
    def set_pos_y(self, pos):
        self.pos_y = pos
    
    def draw(self, surface):
        with surface.beginDraw():
            #mal mir auf der mutter-surface (utterancesArea) deine surface (self.surface)
            surface.image(self.surface, self.pos_x, self.pos_y) 



class Alert(SurfaceBase):
    circle_centers = {}
    notify_info = {}
    i = 0
    a = 0
    start_x = 0
    start_y = 0
    goal_x = 0
    goal_y = 0
    circle_feed_positions = []
    col = color(0)
    
    def __init__(self, name, pos_x, pos_y, s_width, s_height, font):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.font = font
        self.circle_feed_surface = createGraphics(s_width, s_height)
        
    def build_circle_centers(self, circle_dict):
        for cat, cc in circle_dict.items():
            self.circle_centers[cat] = [cc.x, cc.y]
    
    def updateCirclefeed(self, cat, utt):
        self.incoming = True
        self.circle_feed_surface = createGraphics(utt.alert[cat][2], utt.alert[cat][3])
        self.start_x = utt.first_utt[0]
        self.start_y = utt.first_utt[1]
        self.goal_x = self.circle_centers[cat][0] + utt.s_width
        self.goal_y = self.circle_centers[cat][1]
        self.col = color_scheme[cat]
        self.calculate_circle_feed_positions()
        
    def updateNotify(self, cat, counter):
        self.notify_info[cat] = counter.directions[cat].c_limit - counter.category_counter[cat]
        if counter.directions[cat].c_limit > 0 and self.notify_info[cat] >= 0:
            print("cat, c_limit {} {} aktuell: {}\n".format(cat, counter.directions[cat].c_limit, counter.category_counter[cat]))
            alert_text = "Noch {} x {} bis {}".format(self.notify_info[cat], cat, counter.directions[cat].cat_target)
        elif counter.directions[cat].c_limit > 0 and self.notify_info[cat] < 0:
            alert_text = "YEAH"
        else:
            alert_text = "{} hat keinen Effekt auf Song".format(cat)
        alert_surf = linebreak(self.surface.width -20, self.surface.height -20, alert_text, self.font, 20, color_scheme[cat])
        with self.surface.beginDraw():
            self.surface.background(*color_scheme[cat])
            self.surface.imageMode(CENTER)
            self.surface.image(alert_surf, self.surface.width/2, self.surface.height/2)
        print("notify: ", self.notify_info)
        
    def draw(self):
        if len(self.circle_feed_positions) > 0 and self.i < len(self.circle_feed_positions):
            with self.circle_feed_surface.beginDraw():
                self.circle_feed_surface.background(*self.col)
            image(self.circle_feed_surface, self.circle_feed_positions[self.i][0], self.circle_feed_positions[self.i][1])
            self.i += 1
            if self.i == len(self.circle_feed_positions):
                background(255)
        elif keyPressed:
           image(self.surface, self.pos_x, self.pos_y)
        else: 
            self.circle_feed_positions = []
            self.i = 0                 
    
    def calculate_circle_feed_positions(self):
        for i in range(10):
            self.circle_feed_positions.append([lerp(self.start_x, self.goal_x, i/10.0), lerp(self.start_y, self.goal_y, i/10.0), lerp(0, 255, i/10.0)])

class UtterancesArea(SurfaceBase):
    alert = None
    first_utt = []
    
    def __init__(self, name, pos_x, pos_y, s_width, s_height, font, font_bold):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.index = 0
        self.font = font
        self.font_bold = font_bold
        self.alert = {}
    
    def update_utts(self, utt, cat):
        self.incoming = True
        utt_cat = UtteranceLine(self.surface.width, self.surface.height, utt, cat, self.font, self.font_bold, self.pos_x)
        self.alert = {}
        self.first_utt = [self.pos_x + (utt_cat.surface.width - utt_cat.cat_surface.width), self.pos_y]
        self.update_alert(cat, self.first_utt[0], self.first_utt[1], utt_cat.cat_surface.width , utt_cat.cat_surface.height)
        self.add_subsurface(self.index, utt_cat)
        self.index += 1
               
        pos_y = 0
        surfaces_to_iterate = reversed(list(self.subsurfaces.values()))
        for utt_line in surfaces_to_iterate:
            utt_line.set_pos_y(pos_y)
            if pos_y >= self.surface.height:
                break 
            pos_y += utt_line.surface.height
    
        if pos_y > self.surface.height:
            self.subsurfaces.popitem(last=False)  
        
        self.incoming = False
        
    def update_alert(self, cat, alert_x, alert_y, alert_width, alert_height):
        self.alert[cat] = [alert_x, alert_y, alert_width, alert_height]

class Beat:
    def __init__(self, s_width, s_height, beatnum, col, font):
        self.surface = createGraphics(s_width, s_height)
        self.update_beatnum(beatnum, font, col)
    
    def update_beatnum(self, beatnum, font, col):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.surface.textFont(font)
            self.surface.textSize(50)
            self.surface.fill(col)
            self.surface.textAlign(CENTER)
            self.surface.text(beatnum, self.surface.width / 2, self.surface.height * 3 / 5)
        
    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, self.surface.width * 4 / 5, 0)


class Parts:
    def __init__(self, s_width, s_height, current, next, font, col):
        self.surface = createGraphics(s_width, s_height)
        self.update_parts(current, next, font, col)
    
    def update_parts(self, current, next, font, col):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.surface.textFont(font)
            self.surface.textSize(12)
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


class CategoryStar(SurfaceBase):
    textcolor_active = 0, 0, 0
    textcolor_inactive = 200, 200, 200
    textcolor_warning = 255, 0, 0
    linecolor_active = 0, 182, 182
    linecolor_inactive = 200, 200, 200
    circle_radius = 150
    marker_radius = 50
    max_count = 3.

    # a dictionary of type {categrory1: (x1, y1, is_active, limit, target_state), ...} that holds the
    #  - coordinates of the center of the correspponding circle
    #  - whether the target state is set (active)
    #  - REPLACED by CircleClass !!
    #  - stored in :
    __directions = {}
    directions = {}
    category_counter = {}

    # x and y coordinate of the center of the image
    __x = None
    __y = None
    

    def reset(self):
        self.update({}.fromkeys(self.__directions, 0))
        
    def update(self, category_counter, is_locked=False):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.__create_background()
            for cat, count in category_counter.items():
                self.category_counter[cat] = count
                cat_color = color_scheme[cat]
                self.surface.stroke(*cat_color)
                self.surface.strokeWeight(7)
                self.surface.line(self.__x,
                                  self.__y,
                                  self.__x + (self.__directions[cat].x-self.__x) * count/self.max_count,
                                  self.__y + (self.__directions[cat].y-self.__y) * count/self.max_count
                                  )
                self.surface.strokeWeight(1)
                self.surface.stroke(0)
                self.surface.fill(0)
                cc = self.__directions[cat]
                # print("cc {}    c limit: {} ".format(cc.name, cc.c_limit))
                grow = (cc.max_radius - cc.radius) * count/self.max_count
                cc.display(self.surface, grow)
               
            if is_locked:
                self.__show_success_message()

    def update_targets(self, targets):
        for cat, cc in self.__directions.items():
            cc.radius = self.marker_radius # reset circle size
            if cat in targets:
                self.__directions[cat].c_limit = targets[cat][0]
                self.__directions[cat].cat_target = targets[cat][1]
            else:
                self.__directions[cat].cat_target = 'no part available'
        self.reset()

    def init_categories(self, categories):
        self.__create_directions(categories)
        self.reset()

    def __create_background(self):
        self.surface.strokeWeight(2)
        for cat, cc in self.__directions.items():
            self.surface.stroke(0)
            self.surface.fill(100, 150)
            self.surface.line(self.__x, self.__y, cc.x, cc.y)
        self.surface.circle(self.__x, self.__y, self.marker_radius)

    def calc_max_radius(self, x, y):
        if x < self.surface.width/2 and y < self.surface.height/2:
            return min([y, x])
        elif x < self.surface.width/2 and y > self.surface.height/2:
            return min([x, self.surface.height - y])
        elif x > self.surface.width/2 and y < self.surface.height/2:
            return min([self.surface.width - x, y])
        else:
            return min([self.surface.width - x, self.surface.height -y])

    def __create_directions(self, categories):
        self.__x, self.__y = self.surface.width / 2, self.surface.height / 2
        for idx, cat in enumerate(categories):
            circle_color = list(color_scheme[cat]) # list: Circle Class adds a alpha channel
            angle = idx * 2 * math.pi / len(categories)
            x = self.__x + self.circle_radius * math.sin(angle)
            y = self.__y + self.circle_radius * math.cos(angle)
            max_radius = self.calc_max_radius(x, y)
            # print("cat: {}  x {}  y {}".format(cat, x,y))
            self.__directions[cat] = Circle(cat, x, y, angle, self.marker_radius, max_radius, False, 0, 'Unknown', circle_color)
        self.directions = self.__directions # bei x die breite der utt_surf addieren
        
    
    def __show_success_message(self):
        self.surface.fill(*self.textcolor_warning)
        self.surface.text("YEAH!", 20, 20)
        self.surface.fill(255, 255, 255)
