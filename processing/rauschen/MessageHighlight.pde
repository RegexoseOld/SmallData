class MessageHighlight {
  /*
  show incoming Texts on surf1 and surf2
   
   */
  PGraphics surf1, surf2, surf3;
  PGraphics[] surfaces = new PGraphics[2]; // arrays to iterate in displayText
  PVector[] positions = new PVector[2];
  PVector position1, position2, velocity, acceleration;
  String incoming;
  ArrayList<SingleLine> singleList;
  ArrayList<ArrayList<SingleLine>> collection;
  float mass;  
  PFont font;
  float tSize, lowLineY, tWidth, tHeight; // current Size of message
  boolean stopGrow;
  int growMargin, alpha;
  color col;

  MessageHighlight(float m, float x1, float y1, float x2, float y2, PFont font) {
    mass = m;
    position1 = new PVector(x1, y1);
    position2 = new PVector(x2, y2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    buildSurfaces();
    singleList = new ArrayList<SingleLine>();
    collection = new ArrayList<ArrayList<SingleLine>>();
    growMargin = 200;
    this.font = font;
    this.alpha = 255;
    this.col = color(255, this.alpha);
    this.tSize = 10.0;
    this.tWidth = surf1.width/6; // starting point for font calculation
    this.tHeight = surf1.height/6;
    this.lowLineY = 0;
    this.incoming = "";
    this.stopGrow = false;
  }

  void buildSurfaces() {
    surf1 = createGraphics(width *3/7, height/3);
    surf1.smooth();
    surf2 = createGraphics(width *3/7, height/3);
    surf2.smooth();
    surf3 = createGraphics(surf1.width, surf1.height/4);
    surf3.smooth();
    surfaces[0] = surf1;
    surfaces[1] = surf2;
    positions[0] = position1;
    positions[1] = position2;
  }

  void newMessage(String m) {
    this.incoming = m;
    // collection.clear();
  }

  void displayText() {
    if (!stopGrow) {
      calculateTSize(this.tWidth, this.tHeight, this.incoming);
    }
    for (int i=0; i<surfaces.length; i++) {
      // println("i: " + i + " this.tSize: " + this.tSize) ;
      surfaces[i].beginDraw();
      surfaces[i].clear();
      surfaces[i].textFont(this.font);
      //for (Map.Entry me : utterDict.entrySet()) {
      //  String bit = (String) me.getKey();
      //  int bitY = (int) me.getValue();
      // println("bit: " + bit + "  bitY: " + bitY + " this.tSize: " + this.tSize);

      for (SingleLine l : singleList) {  // should be last set of lines
        surfaces[i].rectMode(CORNER);
        surfaces[i].fill(l.col);
        surfaces[i].textSize(this.tSize);
        surfaces[i].text(l.line, 10, l.yPos);
      }
      surfaces[i].endDraw();
      image(surfaces[i], positions[i].x, positions[i].y);
    }
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    // println("force: " + force + "   mass: " + mass + "  f:   " + f);
    acceleration.add(f);
  }

  void calculateTSize(float w, float h, String text2fit) {
    println("\ncalculate size");
    ArrayList<SingleLine> tempsingle = new ArrayList<SingleLine>();
    ArrayList<ArrayList<SingleLine>> tempCollection = new ArrayList<ArrayList<SingleLine>>();    
    StringList textBreak = lineBreak(text2fit, w, this.tSize, this.font);
    println("h   " + h);
    float spacing = textAscent() * 1.5; // font Height
    float y = spacing ;   
    // check if lines will fit the height
    println("height check  " + (h - spacing) + " vs " + (textBreak.size() * spacing));
    if (h - spacing >= (textBreak.size() * spacing) ) {
      // make SingleLine Object to store the in singleList
      for (int i=0; i<textBreak.size(); i++) {
        SingleLine sl = new SingleLine(textBreak.get(i), y);
        // println("line   " + sl.line + "   yPos   " + sl.yPos);
        tempsingle.add(sl);
        y += spacing;
      }
      this.tSize += 1;
    }
    tempCollection.add(tempsingle);
    collection = tempCollection;
    singleList = tempsingle;
    //for (int i=0; i<collection.size(); i++) {
    //  ArrayList<SingleLine> sing = collection.get(i);
    //  singleList = sing;
    //  for (SingleLine l : sing) {
    //    println("line   " + l.line + "   yPos   " + l.yPos);
    //  }
    //}
    print("collection size: " + collection.size() + "   tSize  " + this.tSize);
  }

  void update() {
    // Velocity changes according to acceleration
    velocity.add(acceleration);
    // size changes by velocity1
    if (this.tWidth < surf1.width) {
      this.tWidth +=  velocity.y;   
      this.tHeight += velocity.y *5/9;
      // println("update  tWidth: " + this.tWidth + "  height " + this.tHeight);
    } 
    if (mFade) {
      if (this.tSize + velocity.y > 0) {
        this.tSize += velocity.y; 
        this.alpha -= 20;
        for (List<SingleLine> s : collection) {
          // println("s exists?  " + s);
          for (SingleLine line : s) {
            line.updateCol(this.alpha);
            this.col = currentCol;
          }
        }
      } else {
        mFade = false;
      }
    }
    // We must clear acceleration each frame
    acceleration.mult(0);
  }

  void checkEdge() {
    if (this.tWidth > this.surf1.width -50 && !stopGrow) {
      // println("checkEdge:  " + this.tWidth);
      this.stopGrow = true;
      List<SingleLine> lastEntry = collection.get(collection.size()-1);
      for (SingleLine l : lastEntry) {
        l.setDark();
      }
      createScheduleTimer(1500.0); // stops growing but displays for 3 more seconds
    }
  }


  void reset() {
    this.tSize = 10.0;
    this.tWidth = surf1.width/6;
    this.tHeight = surf1.height/6;
    this.stopGrow = false;
    this.col= 250;
    this.velocity.mult(0);
    this.acceleration.mult(0);
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

  void updateCol(int alpha) {
    col = color(r, g, b, alpha);
  }
  void setDark() {
    col = color(0, 0, 0, a);
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

  // Is the width of the messageRect within  the Margin?
  boolean outMargin(MessageHighlight mH) {
    float l = mH.tWidth;
    if (l > w - mH.growMargin) {
      return true;
    } else {
      return false;
    }
  }

  // Calculate drag force
  PVector drag(MessageHighlight mH) {
    // Magnitude is coefficient * speed squared
    float speed = mH.velocity.mag();
    float dragMagnitude = c * speed * speed;

    // Direction is inverse of velocity
    PVector drag = mH.velocity.copy();
    drag.mult(-1);

    // Scale according to magnitude
    drag.setMag(dragMagnitude);
    return drag;
  }
}
