class MessageHighlight {
  /*
  show incoming Texts on surf1 and surf2
   
   */
  PGraphics[] surfaces = new PGraphics[2]; // arrays to iterate in displayText
  String incoming, related;
  float mass;  
  PFont font;
  float velocity, lastVelocity, acceleration, tSize, tWidth, tHeight, angle; // current Size of message
  boolean stopGrow;

  MessageHighlight(float m, PFont font) {
    mass = m;
    velocity = 0;
    acceleration = 0;
    buildSurfaces();
    angle = 0;
    this.font = font;
    this.tSize = 10.0;
    this.tWidth = incSurf.w/6; // starting point for font calculation
    this.tHeight = incSurf.h/6;
    this.incoming = "";
    this.related = "";
    this.stopGrow = false;
  }

  void newMessage(String m) {
    this.incoming = m;
  }

  void calculateTSize(float w, float h, String text2fit, String messType) {
    // println("\ncalculate size");
    // make temp objects to fill until right fontsize is found
    // all tempsingle Arrays can later be manipulated with their alpha color
    ArrayList<SingleLine> tempsingle = new ArrayList<SingleLine>();
    StringList textBreak = lineBreak(text2fit, w, this.tSize, this.font);
    float spacing = textAscent() * 1.5; // font Height
    float y = spacing ;   
    // check if lines will fit the height
    //println("height check  " + (h - spacing) + " vs " + (textBreak.size() * spacing));
    if (h - spacing >= (textBreak.size() * spacing) ) {
      // make SingleLine Object to store the in singleList
      for (int i=0; i<textBreak.size(); i++) {
        SingleLine sl = new SingleLine(textBreak.get(i), y, this.stopGrow);
        tempsingle.add(sl);
        y += spacing;
      }
      this.tSize += 1;
    }
    if (messType.equals("incomingSurf")) {
      Surface s = surfs[1];
      s.uttLines = tempsingle;
      s.tSize = this.tSize;
    } else if (messType.equals("matchSurf")) {
      Surface s = surfs[2];
      s.uttLines = tempsingle;
      s.tSize = this.tSize;
    }
  }

  void update() {
    // Velocity changes according to acceleration
    velocity += acceleration;
    // println("tSize  " + tSize + "  velocity  " + velocity + "  accel  " + acceleration);
    // size changes by velocity1
    if (this.tWidth < incSurf.w) {
      this.tWidth +=  velocity;   
      this.tHeight += velocity *2/3;
      lastVelocity = velocity/9;
      // println("update  tWidth: " + this.tWidth + "  height " + this.tHeight);
    } 
    // We must clear acceleration each frame
    acceleration = 0;
  }

  void updateFade() {
    lastVelocity += acceleration;
    if (this.tSize > abs(lastVelocity)) {
      this.tSize += lastVelocity;
      for (int i=1; i<=2; i++) {
        Surface s = surfs[i];
        s.tSize = this.tSize;
      }
    } else {
      mFade = false;
      messageLock = false;
      reset();
    }
    acceleration = 0;
  }

  void applyForce(float force) {
    acceleration += force/mass;
  }

  void checkEdge() {
    if (this.tWidth < incSurf.w -50 ) {
      calculateTSize(this.tWidth, this.tHeight, this.incoming, "incomingSurf");
      calculateTSize(this.tWidth, this.tHeight, this.related, "matchSurf");
    } else if (!stopGrow) {
      // println("checkEdge:  " + this.tWidth);
      this.stopGrow = true;
      for (int i = 1; i<=2; i++) {
        Surface s = surfs[i];
        for (SingleLine l : s.uttLines) {
          l.setDark();
        }
      }
      createScheduleTimer(3000.0); // stops growing but displays for 3 more seconds
    }
  }

  void reset() {
    this.tSize = 10.0;
    this.tWidth = incSurf.w/6;
    this.tHeight = incSurf.h/6;
    this.stopGrow = false;
    this.velocity = 0;
    this.acceleration = 0;
    for (int i=1; i<5; i++) {
      Surface s = surfs[i];
      s.visible = false;
    }
  }
}

class SingleLine {
  String line;
  float yPos, r, g, b, a;
  color col;

  SingleLine(String _l, float _y, boolean _grow) {
    line = _l;
    yPos = _y;
    makeColor(_grow);
  }

  void makeColor(boolean grow) {
    if (!grow) {
      int r = (currentCol >> 16) & 0xFF;
      int g = (currentCol >> 8) & 0xFF;
      int b = currentCol & 0xFF;
      int a = (currentCol >> 24) & 0xFF;
      col = color(r, g, b, a);
    } else {
      col = color(230);
    }
  }

  void setDark() {
    col = color(0, 0, 0, 255);
  }
}
