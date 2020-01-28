class Area:
    def __init__(self, tempName, surfaces, pos_x, pos_y):
        self.name = tempName
        self.surfaces = surfaces
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.bg = 222
    
    
    
    def change_bg(self, time_to_change, current_name):
        if time_to_change:
            with self.surface.beginDraw():
                self.surface.background(250)
                self.surface.textFont(Arial, 10)
                self.surface.textAlign(CENTER)
                self.surface.fill(20)
                self.surface.text(current_name, self.surface.width/2, self.surface.height/2)
                self.surface.noFill()
                self.surface.rect(0, 0, self.surface.width/2 -1, self.surface,height/2)
        else:
             with self.surface.beginDraw():
                self.surface.background(222)
                self.surface.textFont(Arial, 10)
                self.surface.textAlign(CENTER)
                self.surface.fill(20)
                self.surface.text(current_name, self.surface.width/2, self.surface.height/2)
                self.surface.noFill()
                self.surface.rect(0, 0, self.surface.width/2 -1, self.surface,height/2)


                
