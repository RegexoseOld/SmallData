class MessageHighlight {
  /*
  show incoming Texts on surf1 and surf2
  
  */
  PGraphics surf1, surf2, surf3;
  PGraphics[] surfaces = new PGraphics[2]; // arrays to iterate in displayText
  PVector[] positions = new PVector[2];
  PVector position1, position2, velocity, acceleration;
  String incoming, related;
  HashMap<String, Integer> utterDict = new HashMap<String, Integer>();
  float mass;  
  PFont font;
  float tSize, tWidth, tHeight; // current Size of message
  boolean stopGrow;
  int growMargin, col;

   MessageHighlight(float m, float x1, float y1, float x2, float y2, PFont font) {
    mass = m;
    position1 = new PVector(x1, y1);
    position2 = new PVector(x2, y2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    buildSurfaces();
    growMargin = 200;
    textFont(font);
    this.col = 200;
    this.tSize = 10.0;
    this.tWidth = 20.0;
    this.tHeight = 10.0;
    this.incoming = "";
    this.related = "";
    this.stopGrow = true;
  }
  
  void buildSurfaces() {
    surf1 = createGraphics(width *3/7, height/3);
    surf1.smooth();
    surf2 = createGraphics(width *3/7, height/3);
    surf2.smooth();
    surf3 = createGraphics(width/5, height/5);
    surfaces[0] = surf1;
    surfaces[1] = surf2;
    positions[0] = position1;
    positions[1] = position2;

  }
  
  void displayText() {
    if (!stopGrow) {
      calculateTSize(this.tWidth, this.tHeight, this.incoming);
    }
    for (int i=0; i<surfaces.length; i++) {
      // println("i: " + i + " this.tSize: " + this.tSize ;
      surfaces[i].beginDraw();
      surfaces[i].clear();
      //surfaces[i].fill(180);
      //surfaces[i].noStroke();
      //surfaces[i].rect(0, 0, this.tWidth, this.tHeight);
      for (Map.Entry me : utterDict.entrySet()) {
        String bit = (String) me.getKey();
        int bitY = (int) me.getValue();
        // println("bit: " + bit + "  bitY: " + bitY + " this.tSize: " + this.tSize);
        surfaces[i].rectMode(CORNER);
        surfaces[i].fill(this.col, 150);
        surfaces[i].textSize(this.tSize);
        surfaces[i].text(bit, 10 , bitY);
      }
      surfaces[i].endDraw();
      image(surfaces[i], positions[i].x, positions[i].y); 
    }
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    //println("force: " + force + "   mass: " + mass + "  f:   " + f);
    acceleration.add(f); 
  }
  
  void calculateTSize(float w, float h, String text2fit) {
    HashMap<String, Integer> tempDict = new HashMap<String, Integer>();
    StringList textBreak = lineBreak(text2fit, w, this.tSize);
     textSize(this.tSize);
     float spacing = textAscent(); // font Height
     int y = 0;   
     // fontSize should grow while there is enough vertical space (y)
     while (y < h  ) {
      for (int i=0; i<textBreak.size(); i++) {
        y += ceil(spacing) * 1.5; 
        tempDict.putIfAbsent(textBreak.get(i), y);
      }
      this.tSize += 1;
      textSize(tSize);
      spacing = textAscent();
    }
    utterDict = tempDict;
  }
  
  void update() {
    // Velocity changes according to acceleration
    velocity.add(acceleration);
    // size changes by velocity1
    if (this.tWidth < surf1.width) {
      this.tWidth +=  velocity.y;   
      this.tHeight += velocity.y *5/9;
      // println("update  tWidth: " + this.tWidth + "  surf1.width " + surf1.width);
    }
    // We must clear acceleration each frame
    acceleration.mult(0);
  }
  
  void checkEdge() {
    if (this.tWidth > this.surf1.width -50 && !stopGrow) {
      // println("checkEdge:  " + this.tWidth);
      this.stopGrow = true;
      this.col = 15;
      createScheduleTimer(3000.0); // stops growing but displays for 5 more seconds
      }
  }
  
  void reset() {
    this.tSize = 15.0;
    this.tWidth = 20.0;
    this.tHeight = 10.0;
    this.stopGrow = false;
    this.col= 250;
    this.velocity.mult(0);
    this.acceleration.mult(0);
    // println("reset   velo:   " + this.velocity + "  acceleration:   " + this.acceleration);
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
