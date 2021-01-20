
fontlist = PFont.list()

class ScaledRotated
  def __init__(self, utterance, category):
    self.utt = utterance
    self.cat = category.toLowerCase()
    print( "cat   {}  shapeMapping.get(self.cat {}".format(self.cat, shapeMapping.get(self.cat))
    self.shape = loadShape(shapeMapping.get(self.cat))
    findColor(self.cat)
    self.x = int(random(width))
    self.y = int(random(height))
    self.font_size = 25
    self.angle = int(random(TWO_PI))
    self.fontName = fontlist[int(random(len(fontlist))]
    self.font = createFont(self.fontName, font_size, True)
  
  def draw():
    textFont(self.font)
    fill(int(random(240)), int(random(0, 125)))
    pushMatrix()
    rotate(self.angle)
    textAlign(CENTER, CENTER)
    textSize(random(40))
    # text(self.utt, self.x, self.y)
    lights()
    self.shape.disableStyle()
    fill(shapeColor)
    float shapeSize = random(35)
    shape(self.shape, self.x, self.y, shapeSize, shapeSize
    moveText()
    popMatrix()

  
  def moveText():
    if self.x < width and self.y < height:
        self.x +=10
        self.y +=10
    else:
        self.x = int(random(width))
        self.y = int(random(height))
    }
    self.angle+=1
  
  def matchInput(incoming):
      if self.utt == incoming and not messageLock: 
        messageLock = true
        mH.reset()
        mH.related = self.utt;
        print("matched! {}  with {}".format(incoming, self.utt))
        # pMillis = millis();

  def findColor(cat):
    switch(cat):
      case "praise" : shapeColor = color(171, 138, 132, 175)
      break
      case "dissence" : shapeColor = color(181, 201, 187, 125)
      break
      case "insinuation" : shapeColor = color(120, 145, 148, 125)
      break
      case "lecture" : shapeColor = color(109, 133, 124, 125)
      break
      case "concession" : shapeColor = color(198, 199, 177, 180)
      
