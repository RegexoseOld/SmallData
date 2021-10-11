class TextCalculations {

  // tc  hat die Aufgabe, fontsizes und SingleLine Objekte zu animieren
  // tc bekommt w, h, text, font
  PGraphics s; // surface to calculate text sizes
  float mass;  
  float velocity, lastVelocity, acceleration, tSize, angle; 
  int tWidth, tHeight; // growing area of text. starts low; ends if area is approaching the maximum width of this client surface
  boolean stopGrow;

  TextCalculations(float _m, PGraphics _s) {
    this.mass = _m;
    this.s = _s;
    velocity = 0;
    acceleration = 0;
    angle = 0;
    this.tSize = 10.0;
    this.tWidth = this.s.width/6; // starting point for font calculation
    this.tHeight = this.s.height/6;
    this.stopGrow = false;
  }

  void applyForce(float force) {
    acceleration += force/mass;
  }

  void update(int w) {
    // Velocity changes according to acceleration
    velocity += acceleration;
    // println("tSize  " + tSize + "  velocity  " + velocity + "  accel  " + acceleration);
    // velocity increases the area tWidth to calculate the fontSize for
    if (this.tWidth < w) {
      this.tWidth +=  velocity;   
      this.tHeight += velocity *2/3;
      lastVelocity = velocity/9;
      // println("update  tWidth: " + this.tWidth + "  height " + this.tHeight);
    } 
    // We must clear acceleration each frame
    acceleration = 0;
  }

  void checkEdge(int w, PFont font, float tSize, String t, Kinship k) {
    if (this.tWidth <= w - 50 ) {
      calculateTSize(this.tWidth, this.tHeight, tSize, t, this.stopGrow, font, k);
    } else {
      println("checkEdge:  " + this.tWidth);
      k.stopGrow = true;
      k.setDark();
      createScheduleTimer(3000.0); // stops growing but displays for 3 more seconds
    }
  }

  void calculateTSize(float w, float h, float fontSize, String text2fit, boolean grow, PFont font, Kinship k) {
    // println("\ncalculate size" + k.name);
    // make temp objects to fill until right fontsize is found
    // all tempsingle Arrays can later be manipulated with their alpha color
    ArrayList<SingleLine> tempsingle = new ArrayList<SingleLine>();
    StringList textBreak = lineBreak(text2fit, w, fontSize, font);
    float spacing = textAscent() * 1.5; // font Height
    float y = spacing ;   
    // check if lines will fit the height of the surface
    while (h - spacing >= (textBreak.size() * spacing) ) {
      // make SingleLine Object to store the in singleList
      fontSize += 1;
      textBreak = lineBreak(text2fit, w, fontSize, font);
      spacing = textAscent() * 1.5; // font Height
      y = spacing ;
    }
    for (int i=0; i<textBreak.size(); i++) {
      SingleLine sl = new SingleLine(textBreak.get(i), y, grow);
      tempsingle.add(sl);
      y += spacing;
    }
    k.uttLines = tempsingle;
    k.tSize = int(floor(fontSize));
  }

  void updateFade(Kinship k) {
    lastVelocity += acceleration;
    if (this.tSize > abs(lastVelocity)) {
      this.tSize += lastVelocity;
      println("update fade" + this.tSize);
      k.tSize = int(this.tSize);
    } else {
      println("time to disappear");
      // k.visible = false;
      k.matched = false;
    }
    acceleration = 0;
  }

  void reset() {
    this.tSize = 1.0;
    this.tWidth = incSurf.w/6;
    this.tHeight = incSurf.h/6;
    this.velocity = 0;
    this.acceleration = 0;
  }

  StringList lineBreak(String s, float maxWidth, float tSize, PFont font) {
    // println("String s  " + s + "  maxWidth   " + maxWidth + "  tSize   " + tSize);
    // Make an empty ArrayList
    StringList a = new StringList();
    textFont(font);
    textSize(tSize);
    float w = 0;    // Accumulate width of chars
    int i = 0;      // Count through chars
    int rememberSpace = 0; // Remember where the last space was. pausiert, weil problem
    // As long as we are not at the end of the String
    while (i < s.length()) {
      // Current char
      char c = s.charAt(i);
      w += textWidth(c); // accumulate width
      // println("c  " + c + "  w  " + w + "  i  " + i + "  maxw  "+ maxWidth + "   tSize   " + tSize);
      if (c == ' ') {
        rememberSpace = i;
      } // Are we a blank space? we need to get at least one word in a line. What about long words
      if (w > maxWidth) {  // Have we reached the end of a line?
        if (rememberSpace == 0) {
          rememberSpace = i;
        }
        String sub = s.substring(0, rememberSpace); // Make a substring. 
        // println("i  " + i + "  sub   " + sub + "remember   " + rememberSpace);
        // Chop off space at beginning
        if (sub.length() > 0 && sub.charAt(0) == ' ') {
          sub = sub.substring(1, sub.length());
        }
        // Add substring to the list
        a.append(sub);
        // Reset everything
        s = s.substring(rememberSpace, s.length());
        i = 0;
        w = 0;
      } else {
        i++;  // Keep going!
      }
    }
    // Take care of the last remaining line
    if (s.length() > 0 && s.charAt(0) == ' ') {
      s = s.substring(1, s.length());
      // println("last line   " + s);
    }
    a.append(s);
    // println("linebreak size   " + a.size());
    return a;
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
