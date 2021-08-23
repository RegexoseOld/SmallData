from collections import OrderedDict
import math


color_scheme = {'dissence': color(150, 150, 150),
                'insinuation': color(30, 101, 109),
                'lecture': color(30, 150, 109),
                'praise': color(246, 41, 0),
                'concession': color(241, 243, 150)
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

class Beat:

    def __init__(self, s_width, s_height, beatnum, col, font):
        self.surface = createGraphics(s_width, s_height)
        self.update_beatnum(beatnum, font, col)

    def update_beatnum(self, beatnum, font, col):
        with self.surface.beginDraw():
            self.surface.background(222)
            self.surface.textFont(font)
            self.surface.textSize(150)
            self.surface.fill(col)
            self.surface.textAlign(CENTER)
            self.surface.text(
                beatnum, self.surface.width / 2, self.surface.height * 3 / 5)

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
            # self.surface.textSize(25)
            self.surface.fill(0)
            self.surface.textAlign(CENTER)
            self.surface.text(
                "current part:\n" + current, self.surface.width / 2, self.surface.height / 4)
            self.surface.text(
                "next part:\n" + next, self.surface.width / 2, self.surface.height * 3 / 4)

    def draw(self, surface):
        with surface.beginDraw():
            surface.image(self.surface, 0, 0)

class SongStatus:
    counter = OrderedDict()
    rect_height = 5

    def __init__(self, pos_x, pos_y, s_width, s_height, font):
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.surface = createGraphics(s_width, s_height)
        self.font = font

    def draw(self):
        image(self.surface, self.pos_x, self.pos_y)

    def update_status(self, new_counter, machine_is_locked):
        # print(new_counter)
        self.counter = new_counter
        with self.surface.beginDraw():
            
            
            if machine_is_locked:
                self.surface.background(123)
                self.surface.text("LOCKED", self.surface.width/2, self.surface.height/2)
            else:
                self.surface.background(222)
                xPosBar = self.surface.width / 6
                yPosBar = self.surface.height * 4 / 5
                bar_width = self.surface.width / 20
                progress = 30
                spacing = 50
    
                i = 0
                for cat, v in self.counter.items():
                    col = color_scheme[cat]
                    rect_count = v['count']
                    lim = v['limit']
                    # print("cat {}   count {}   col {} ".format(cat, rect_count, col))
                    self.surface.fill(col)
                    self.surface.noStroke()
                    self.surface.rect(spacing + (xPosBar * i), yPosBar, bar_width, -rect_count * progress)
                    self.surface.stroke(255, 0, 0)
                    self.surface.strokeWeight(3)
                    self.surface.line(spacing + (xPosBar * i), yPosBar - (lim * progress), spacing + (xPosBar * i) + bar_width, yPosBar - (lim * progress))
                    self.surface.fill(0)
                    self.surface.pushMatrix()
                    self.surface.translate(spacing + (xPosBar * i), yPosBar + 20)
                    self.surface.rotate(QUARTER_PI)
                    self.surface.text(cat, 0, 0)
                    self.surface.popMatrix()
                    i += 1

class PartArea(SurfaceBase):

    def __init__(self, name, pos_x, pos_y, s_width, s_height, font):
        SurfaceBase.__init__(self, name, pos_x, pos_y, s_width, s_height)
        self.font = font

    def update_parts(self, current, next, beatnum, change):
        if change == "True":
            col = color(250, 0, 20)
        else:
            col = color(10, 250, 0)
        beat_surf = Beat(
            self.surface.width / 3, self.surface.height, beatnum, col, self.font)
        current_next_surf = Parts(
            self.surface.width / 3, self.surface.height, current, next, self.font, col)
        self.add_subsurface("beat", beat_surf)
        self.add_subsurface("parts", current_next_surf)
