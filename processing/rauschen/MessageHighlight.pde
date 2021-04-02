class MessageHighlight {
  /*
  show incoming Texts on surf1 and surf2
   
   */
  PGraphics[] surfaces = new PGraphics[2]; // arrays to iterate in displayText
  String incoming, related;
  ArrayList<SingleLine> incList, relList;
  float mass;  
  PFont font;
  float velocity, acceleration, tSize, tWidth, tHeight, angle; // current Size of message
  boolean stopGrow;
  int growMargin, alpha;
  color col;

  MessageHighlight(float m, PFont font) {
    mass = m;
    velocity = 0;
    acceleration = 0;
    buildSurfaces();
    incList = new ArrayList<SingleLine>();
    relList = new ArrayList<SingleLine>();
    growMargin = 200;
    angle = 0;
    this.font = font;
    this.alpha = 125;
    this.col = color(255, this.alpha);
    this.tSize = 10.0;
    this.tWidth = incSurf.w/6; // starting point for font calculation
    this.tHeight = incSurf.h/6;
    this.incoming = "";
    this.related = "";
    this.stopGrow = false;
  }

  void newMessage(String m) {
    this.incoming = m;
    // collection.clear();
  }

  void displayText() {

    for (int i=1; i<=2; i++) {
      Surface s = surfs[i];
      ArrayList<SingleLine> list = new ArrayList<SingleLine>();
      if (i == 1) { 
        list = incList;
      } else if (i == 2) {
        list = relList;
      }
      s.displayUtt(list, this.tSize);
    }
  }

  void applyForce(float force) {
    acceleration += force/mass;
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
        SingleLine sl = new SingleLine(textBreak.get(i), y);
        tempsingle.add(sl);
        y += spacing;
      }
      this.tSize += 1;
    }
    if (messType.equals("incomingSurf")) {
      incList = tempsingle;
    } else if (messType.equals("matchSurf")) {
      relList = tempsingle;
    }
  }

  void update() {
    // Velocity changes according to acceleration
    velocity += acceleration;
    // size changes by velocity1
    if (this.tWidth < incSurf.w) {
      this.tWidth +=  velocity;   
      this.tHeight += velocity *2/3;
      // println("update  tWidth: " + this.tWidth + "  height " + this.tHeight);
      if (!stopGrow) {
        calculateTSize(this.tWidth, this.tHeight, this.incoming, "incomingSurf");
        calculateTSize(this.tWidth, this.tHeight, this.related, "matchSurf");
      }
    } 
    if (mFade) {
      // display dupSurfs to erase previously drawn text
      // wann ist fade zu ende?
      if (this.tSize > abs(velocity)) {
        this.tSize += velocity; 
        for (int i=1; i<5; i++) {
          Surface surf = surfs[i];
          fadeGraphics(surf.s, 10);
          // println("fading " + surf.name);
        }
      } else {
        mFade = false;
        messageLock = false;
        reset();
      }
    }
    // We must clear acceleration each frame
    acceleration = 0;
  }

  void fadeGraphics(PGraphics c, int fadeAmount) {
    c.beginDraw();
    c.loadPixels();
    // iterate over pixels
    for (int i =0; i<c.pixels.length; i++) {
      // get alpha value
      int alpha = (c.pixels[i] >> 24) & 0xFF ;
      // reduce alpha value
      alpha = max(0, alpha-fadeAmount);
      // assign color with new alpha-value
      c.pixels[i] = alpha<<24 | (c.pixels[i]) & 0xFFFFFF ;
    }
    c.updatePixels();
    c.endDraw();
  }


  void checkEdge() {
    if (this.tWidth > incSurf.w -50 && !stopGrow) {
      // println("checkEdge:  " + this.tWidth);
      this.stopGrow = true;
      for (SingleLine l : incList) {
        l.setDark();
      }
      for (SingleLine l : relList) {
        l.setDark();
      }
      createScheduleTimer(3000.0); // stops growing but displays for 3 more seconds
    }
  }


  void reset() {
    this.tSize = 10.0;
    this.tWidth = incSurf.w/6;
    this.tHeight = incSurf.h/6;
    this.alpha = 255;
    this.stopGrow = false;
    this.col= 250;
    this.velocity = 0;
    this.acceleration = 0;
    // println("reset   velo:   " + this.velocity + "  acceleration:   " + this.acceleration);
  }
}

class SingleLine {
  String line;
  float yPos, r, g, b, a;
  color col;

  SingleLine(String _l, float _y) {
    line = _l;
    yPos = _y;
    makeColor();
  }

  void makeColor() {
    int r = (currentCol >> 16) & 0xFF;
    int g = (currentCol >> 8) & 0xFF;
    int b = currentCol & 0xFF;
    int a = (currentCol >> 24) & 0xFF;
    col = color(r, g, b, a);
  }

  //void updateCol(int alpha) {
  //  col = color(r, g, b, alpha);
  //}
  void setDark() {
    col = color(0, 0, 0, 255);
  }
}

class Margin {

  // Margin is a rectangle
  float x, y, w, h;
  // Coefficient of drag
  float c;

  Margin(float w_, float h_, float c_) {
    w = w_;
    h = h_;
    c = c_;
  }

  // Is the width of the messageRect within the Margin?
  boolean outMargin(MessageHighlight mH) {
    float l = mH.tWidth;
    if (l > w - mH.growMargin) {
      return true;
    } else {
      return false;
    }
  }

  // Calculate drag force
  float drag(MessageHighlight mH) {
    // Magnitude is coefficient * speed squared
    float speed = mH.velocity;
    float dragMagnitude = c * speed * speed;

    // Direction is inverse of velocity
    PVector drag =  new PVector(mH.velocity, 0) ;
    drag.mult(-1);

    //    // Scale according to magnitude
    drag.setMag(dragMagnitude);
    return drag.x;
  }
}
