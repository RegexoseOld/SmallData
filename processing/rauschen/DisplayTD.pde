class DisplayTD {
  PFont font;
  int font_size, index;
  float x, y, sX, sY, angle;
  PVector pos;
  String utt, cat, user, fontName;
  PShape shape;
  RShape rS;
  Area area;
  color shapeColor; 
  boolean isShape;
  float shapeSize;

  DisplayTD(int index, String utterance, String category, String _user, PShape shape, float sSize, boolean isShape) {
    this.index = index;
    this.utt = utterance;
    this.cat = category.toLowerCase();
    this.user = _user;
    this.isShape = isShape;
    this.shape = shape;
    this.shapeSize = sSize;
    shapeColor = attributeUtt(this.cat);
    this.area = areas.findArea(this.cat);
    this.rS = this.area.rS;
    this.pos = new PVector(this.rS.getCenter().x, this.rS.getCenter().y);
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }

  void draw() {
    mainSurf.s.beginDraw();
    mainSurf.s.textFont(this.font);
    mainSurf.s.fill(this.shapeColor, 60);
    // mainSurf.s.fill(this.shapeColor);
    mainSurf.s.pushMatrix();
    mainSurf.s.translate(this.x, this.y);
    mainSurf.s.rotate(this.angle);
    this.shape.disableStyle();
    mainSurf.s.fill(shapeColor);
    mainSurf.s.shape(this.shape, 0, 0, this.shapeSize, this.shapeSize);
    moveText();
    mainSurf.s.popMatrix();
    mainSurf.s.endDraw();
  }

  void moveText() {
    int d = 4;
    float aW = this.rS.getWidth() ;
    float aH = this.rS.getHeight();
    this.x = random(this.area.centerOfArea.x - aW/d, this.area.centerOfArea.x + aW/d);
    this.y = random(this.area.centerOfArea.y - aH/d, this.area.centerOfArea.y + aH/d);
    if (this.x < width && this.y < height) {
      this.x += random(-10, 10);
      this.y += random(-8, 8);
    } 
    this.angle += random(-0.05, 0.05);
  }

  void matchInput(String incoming) {
    if (this.utt.equals(incoming) && !messageLock && !matchedUtts.hasValue(incoming) && !mFade) {
      messageLock = true;
      mH.related = this.utt;
      // println("matched!  " + incoming + "    with index  " + this.index);
      matchedUtts.append(incoming);
      titleSurf1.col = shapeColor;
      titleSurf2.col = attributeUtt(cat);
    }
  }
}


color attributeUtt(String cat) {
  color col = color(0);
  switch(cat) {
  case "praise" : 
    // col =  color(171, 138, 132, 150);
    col =  color(196, 128, 79);
    break;
  case "dissence" : 
    col = color(150, 63, 146);
    break;
  case "insinuation" : 
    col =  color(21, 143, 84);
    break;
  case "lecture" : 
    col = color(23, 139, 189);
    break;
  case "concession" : 
    col = color(133, 138, 37);
  }
  return col;
}
