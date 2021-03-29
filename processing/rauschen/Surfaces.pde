class Surface {
  PVector pos;
  PGraphics s;
  PFont font;
  String name, message;
  int w, h;
  float  tSize;
  boolean fixed;
  color col;

  Surface(String name, float _x, float _y, float _w, float _h, PFont _font, boolean _fixed) {
    this.name = name;
    this.pos = new PVector(_x, _y);
    w = int(_w);
    h = int(_h);
    this.s = createGraphics(w, h);
    this.s.smooth();
    this.font = _font;
    this.fixed = _fixed;
    this.message= "";
    this.tSize = 1;
  }

  void updateMessage(String m, color c, float size) {
    this.tSize= size;
    this.message = m;
    this.col = c;
  }

  void display(String name) {
    if (name.equals("infoSurf")) {
      displayInfo();
    } else if (name.startsWith("title")) {
      displayTitle();
    }
  }

  void displayUtt(ArrayList<SingleLine> list, float size) {
    this.s.beginDraw();
    for (SingleLine sl : list) {
      this.s.clear();
      this.s.textFont(this.font, size);
      this.s.fill(sl.col);
      this.s.text(sl.line, 10, sl.yPos);
    }
    this.s.endDraw();
  }

  void displayInfo() {
    this.s.beginDraw();
    this.s.background(222);
    this.s.textFont(font);
    this.s.fill(20, 200);
    this.s.rectMode(CORNER);
    // progress bar for remaining Timer
    this.s.text(incomingText + "\t     " + incomingCat, 0, this.s.height/4, this.s.width, this.s.height);
    this.s.fill(189, 10, 10, 150);
    this.s.rect(0, 0, uttCount * prgIncrement, this.s.height/4);
    this.s.endDraw();
  }
  void displayTitle() {
    this.s.beginDraw();
    this.s.background(222, 0, 0);
    this.s.textFont(this.font);
    this.s.textAlign(CENTER, CENTER);
    this.s.fill(this.col);
    this.s.text(this.message, this.w/2, this.h/2);
    this.s.fill(189, 10, 10, 150);
    this.s.rect(0, 0, uttCount * prgIncrement, this.s.height/4);
    this.s.endDraw();
  }
}

void buildSurfaces() {
  println("x " + width/30 + " y " + height/2 + " w " +  width *3/7 + " h " + height/5);
  incSurf = new Surface("incomingSurf", width/30, height/2, width *3/7, height/5, messageFont, false);
  matchSurf = new Surface("matchSurf", width *5/9, height/2, width *3/7, height/5, messageFont, false);
  titleSurf1 = new Surface("titleIncoming", incSurf.pos.x, incSurf.pos.y-80, incSurf.w, 50.0, messageFont, true);
  titleSurf2 =  new Surface("titleMatch", matchSurf.pos.x, matchSurf.pos.y-80, matchSurf.w, 50.0, messageFont, true);
  infoSurf = new Surface("infoSurf", 0, height-height/15, width, height/15, infoFont, true);
  surfs[0] = incSurf;
  surfs[1] = matchSurf;
  surfs[2] = titleSurf1;
  surfs[3] = titleSurf2;
  surfs[4] = infoSurf;
  titleSurf1.updateMessage("Dein Kommentar ähnelt...", color(0), 12);
  titleSurf2.updateMessage("...diesem hier", color(0), 12);
}
