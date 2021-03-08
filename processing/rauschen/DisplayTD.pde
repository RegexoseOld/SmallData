class DisplayTD {
  PFont font;
  int font_size, index;
  float x, y, sX, sY, angle;
  String utt, cat, fontName;
  PShape shape;
  RShape area;
  color shapeColor; 
  boolean isShape, matched;
  float shapeSize;

  DisplayTD(int index, String utterance, String category, PShape shape, float sSize, boolean isShape) {
    this.index = index;
    this.utt = utterance;
    this.cat = category.toLowerCase();
    this.isShape = isShape;
    this.matched = false; // should be checked only once between to incoming messages: line 70
    this.shape = shape;
    this.shapeSize = sSize;
    attributeUtt(this.cat);
    findArea();
    this.font_size = 25;
    this.angle = int(random(TWO_PI));
    this.fontName = fontlist[int(random(fontlist.length))];
    this.font = createFont(this.fontName, font_size, true);
  }

  void draw() {
    textFont(this.font);
    fill(this.shapeColor, int(random(0, 80)));
    pushMatrix();
    translate(this.x, this.y);
    rotate(this.angle);
    if (this.isShape) {
      this.shape.disableStyle();
      fill(shapeColor);
      shape(this.shape, 0, 0, this.shapeSize, this.shapeSize);
    } else if (!this.isShape) {
      textAlign(CENTER, CENTER);
      textSize(random(40));
      text(this.utt, 0, 0);
    }
    moveText();
    popMatrix();
  }

  void findArea() {
    for (Area a : areas.areas) {
      if (a.name.equals(this.cat)) {
        this.area = a.rS;
        RPoint center = area.getCenter();
        float aW = area.getWidth();
        float aH = area.getHeight();
        this.x = random(center.x - aW/3, center.x + aW/3);
        this.y = random(center.y - aH/3, center.y + aH/3);
        // println("   cat   " + this.cat + " x  " + this.x + "   y  " + this.y);
      }
    }
  }

  void moveText() {
    if (this.x < width && this.y < height) {
      this.x += random(-10,10);;
      this.y += random(-8,8);
    } 
    this.angle += random(-0.05, 0.05);
  }

  void matchInput(String incoming) {
    if (this.utt.equals(incoming) && !messageLock && !this.matched && !mFade) {
      messageLock = true;
      mH.reset();
      this.matched = true;
      // println("matched!  " + incoming + "    with   " + this.utt);
    }
  }

  void attributeUtt(String cat) {
    switch(cat) {
    case "praise" : 
      shapeColor = color(171, 138, 132, 175);
      break;
    case "dissence" : 
      shapeColor = color(181, 201, 187, 125);
      break;
    case "insinuation" : 
      shapeColor = color(120, 145, 148, 125);
      break;
    case "lecture" : 
      shapeColor = color(109, 133, 124, 125);
      break;
    case "concession" : 
      shapeColor = color(198, 199, 177, 180);
    }
  }
}
