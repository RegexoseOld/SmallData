class DisplayTD{
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
    this.shape.disableStyle();
    this.shapeSize = sSize;
    this.shapeColor = findColor(this.cat);
    this.area = areas.findArea(this.cat);
    this.rS = this.area.rS;
    this.pos = this.area.areaPos.get(3);
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }

  void update() {
    rauschSurf.updateDisplay(this.shape, this.pos, this.shapeSize, this.angle, this.shapeColor);
    move();
  }

  void move() {
    int rIndex = int(random(this.area.areaPos.size()));
    this.pos = this.area.areaPos.get(rIndex);
    this.angle += random(-0.05, 0.05);
  }

  void matchInput(String incoming) {
    if (this.utt.equals(incoming) && !messageLock && !matchedUtts.hasValue(incoming) && !mFade) {
      messageLock = true;
      mH.related = this.utt;
      // println("matched!  " + incoming + "    with index  " + this.index);
      matchedUtts.append(incoming);
      incSurf.col = shapeColor;
      matchSurf.col = findColor(cat);
    }
  }
}


color findColor(String cat) {
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
