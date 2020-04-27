

class Circle:
    
    def __init__(self, name, x, y, angle, radius, is_active, count_limit, next_part_name, col, inflate):
        self.name = name
        self.x = x
        self.y = y
        self.angle = angle
        self.radius = radius
        self.is_active = is_active
        self.c_limit = count_limit
        self.next_part_name = next_part_name
        self.col = col
        self.inflate = inflate
    
    def display(self, surface):
        x = self.x + self.radius * sin(self.angle)
        y = self.y + 2 * self.radius * cos(self.angle)
        with surface.beginDraw(): 
            surface.fill(*self.col)
            surface.circle(self.x, self.y, self.radius * self.inflate)
            surface.fill(0)
            surface.text(self.next_part_name, x, y)
    
    def intersects(self, other):
        if dist(self.x, self.y, other.x, other.y) < (self.radius + other.radius):
            print ("intersecting")
            self.col = (self.col, 30)
            return True
        else:
            return False
