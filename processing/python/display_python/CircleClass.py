

class Circle:
    tp = 150 
    
    def __init__(self, name, x, y, angle, radius, max_radius, is_active, count_limit, cat_target, col):
        self.name = name
        self.x = x
        self.y = y
        self.angle = angle
        self.radius = radius
        self.max_radius = max_radius
        self.is_active = is_active
        self.c_limit = count_limit
        self.cat_target = cat_target
        self.col = col
        self.col.append(self.tp)
    
    def display(self, surface, grow):
        x = self.x + self.radius * sin(self.angle)
        y = self.y + self.radius * cos(self.angle)
        with surface.beginDraw(): 
            # print('max radius: ', self.max_radius)
            surface.fill(*self.col)
            surface.circle(self.x, self.y, self.radius + grow)
            surface.rectMode(CENTER)
            surface.noFill()
            surface.rect(x, y, textWidth(self.cat_target), 18)
            surface.fill(0)
            surface.textAlign(CENTER)
            surface.text(self.cat_target, x, y)
    
