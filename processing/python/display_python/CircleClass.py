

class Circle:
    tp = 150 
    
    def __init__(self, name, x, y, angle, radius, max_radius, is_active, count_limit, next_part_name, col, inflate):
        self.name = name
        self.x = x
        self.y = y
        self.angle = angle
        self.radius = radius
        self.max_radius = max_radius
        self.is_active = is_active
        self.c_limit = count_limit
        self.next_part_name = next_part_name
        self.col = [c for c in col]
        self.col.append(self.tp)
        self.inflate = inflate
    
    def display(self, surface):
        x = self.x + self.radius * sin(self.angle)
        y = self.y + 2 * self.radius * cos(self.angle)
        self.radius = self.max_radius - (self.max_radius - self.radius) / self.inflate
        with surface.beginDraw(): 
            print('self.col: ', self.col)
            surface.fill(*self.col)
            surface.circle(self.x, self.y, self.radius)
            surface.fill(0)
            surface.text(self.next_part_name, x, y)
    
    def intersects(self, other):
        # print("radiae: " , self.radius + other.radius)
        if dist(self.x, self.y, other.x, other.y) < (self.radius + other.radius):
            print ("intersecting")
            self.col[3] = self.tp
            # print('self.col: ', self.col)
            return True
        else:
            return False
