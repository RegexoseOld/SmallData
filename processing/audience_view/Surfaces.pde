class SurfaceBase { //<>//
  String name;
  int w, h;
  PVector pos;
  PFont font;
  boolean visible;
  PGraphics surf;

  SurfaceBase(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible ) {
    this.name = name;
    this.pos = new PVector(_x, _y);
    this.w = _w;
    this.h = _h;
    this.surf = createGraphics(_w, _h);
    this.surf.smooth();
    this.font = _font;
    this.visible = _visible;
  }

  void display() {
    image(this.surf, this.pos.x, this.pos.y);
  }

  void clearBackground() {
    this.surf.beginDraw();
    this.surf.background(222);
    this.surf.endDraw();
  }
}

class Article extends SurfaceBase {
  String currentLine;

  Article(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.currentLine = "";
  }

  void updateLine(String l) {
    this.surf.beginDraw();
    this.surf.background(180);
    this.surf.textFont(this.font, 12);
    this.surf.textAlign(LEFT, TOP);
    this.surf.fill(0);
    this.currentLine = l;
    // println("performer current line " + this.currentLine);
    this.surf.text(this.currentLine, 0, 0);
    this.surf.endDraw();
  }
}

class Rauschen extends SurfaceBase {  

  Rauschen(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
  }
  void updateDisplay(PShape s, PVector p, float size, float a, color col ) {
    this.surf.beginDraw();
    this.surf.pushMatrix();
    this.surf.translate(p.x, p.y);
    this.surf.rotate(a);
    this.surf.fill(col);
    this.surf.shape(s, 0, 0, size, size);
    this.surf.popMatrix();
    this.surf.endDraw();
  }

  void areaOutlines(RPoint p, RPoint prv, RPoint c, int offset, color col) {
    this.surf.beginDraw();
    this.surf.stroke(col);
    this.surf.strokeWeight(5);
    this.surf.line(p.x, p.y, prv.x, prv.y);
    this.surf.strokeWeight(15);
    this.surf.point(p.x, p.y);
    this.surf.strokeWeight(25);
    this.surf.fill(col);
    this.surf.textFont(this.font, 30);
    this.surf.text(this.name, c.x + offset, c.y);
    this.surf.endDraw();
  }
}

class Kinship extends SurfaceBase {
  ArrayList<SingleLine> uttLines;
  int tSize;
  boolean reset;
  PGraphics titleSurf;
  color col;
  String title;

  Kinship(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.uttLines = new ArrayList<SingleLine>();
    this.titleSurf = createGraphics(_w, _h/10);
    this.reset = false;
  }
  void displayMatch() {
    makeTitle();
    this.surf.beginDraw();
    // this.s.clear();
    this.surf.background(222);
    for (SingleLine sl : this.uttLines) {
      this.surf.textFont(this.font, this.tSize);
      this.surf.fill(sl.col);
      this.surf.text(sl.line, 10, sl.yPos);
    }
    this.surf.endDraw();
  }

  void makeTitle() {
    if (this.name.equals("incoming")) {
      this.title = "Dein Kommentar ähnelt ...";
    } else { 
      this.title= " ... diesem hier";
    }
    this.titleSurf.beginDraw();
    // remove alpha color
    int alpha = (this.col >> 24) & 0xFF;
    alpha = 255;
    this.col = alpha<<24 | this.col & 0xFFFFFF ;
    this.titleSurf.background(this.col);
    this.titleSurf.textFont(this.font);
    this.titleSurf.textAlign(CENTER, CENTER);
    this.titleSurf.fill(20);
    this.titleSurf.text(this.title, this.w/2, this.h/2);
    this.titleSurf.endDraw();
  }

  void setDark() {
    this.surf.beginDraw();
    for (SingleLine l : this.uttLines) {
      l.setDark();
    }
    this.surf.endDraw();
  }
}

class Info extends SurfaceBase {

  Info(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
  }

  void displayInfo() {
    String cat = translatedCats.getString(incomingCat);
    this.surf.beginDraw();
    this.surf.background(222);
    this.surf.textFont(this.font, 15);
    this.surf.fill(20, 200);
    this.surf.rectMode(CORNER);
    // progress bar for remaining Timer
    this.surf.text(incomingText + "\t     " + cat, 0, this.surf.height/4, this.surf.width, this.surf.height);
    this.surf.fill(189, 10, 10, 150);
    this.surf.rect(0, 0, uttCount * prgIncrement, this.surf.height/4);
    this.surf.text("Wir sind im / We are in the \t\t - - " + currentPart + " - - \t \t  Teil / Part", 0, this.surf.height *2/3, this.surf.width, this.surf.height);
    this.surf.endDraw();
  }
}

class Sculpture extends SurfaceBase {

  Sculpture(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
  }

  void displaySculpture(String msg) {
    Area a = areas.findArea(incomingCat);
    a.sculptureText();
    // println("area name  " + a.name + "   pos  " + pos);
    this.surf.beginDraw();
    this.surf.textFont(this.font);
    this.surf.textSize(20);
    this.surf.textAlign(TOP, TOP);
    this.surf.pushMatrix();
    this.surf.translate(a.sC.x, a.sC.y);
    this.surf.rotate(a.textAngle);
    this.surf.fill(255);
    this.surf.noStroke();
    println("text Ascent " + textAscent() + "text Width:  " + textWidth(msg) );
    this.surf.rect(0, 0, textWidth(msg), textAscent() * 0.7);
    this.surf.fill(a.col);
    this.surf.text(msg, 0, 0);
    this.surf.popMatrix();


    this.surf.endDraw();
    a.textAngle += a.progressAngle;
  }
}

class Surface { 
  /*
  Surfaces haben verschiedene Funktionen
   permanent = main und infosurf, sind immer visible
   matched: 4 Surfs visible. Utt surfs sind animiert (displayUTT), 
   titlesurfs sind statisch und werden ein und ausgeblendet (displayTitle, fadeTitle)
   es gilt, eine display Funktion zu schreiben, die je nach status verschiedene Surfaces erzeugt und malt.
   */
  PVector pos;
  PGraphics s;
  PFont font;
  String name, message;
  ArrayList<SingleLine> uttLines;
  int w, h, lineIndex, alpha;
  float  tSize;
  boolean visible, fade, active, reset;
  color col;

  Surface(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible, String _message) {
    this.name = name;
    this.w = _w;
    this.h = _h;
    this.pos = new PVector(_x, _y);
    this.s = createGraphics(_w, _h);
    this.s.smooth();
    this.font = _font;
    this.visible = _visible;
    this.fade = false;
    this.active = true;
    this.reset = false;
    this.message= _message;
    initSurf();
  }

  void initSurf() {
    if (this.name.startsWith("title")) {
      makeTitle();
    }
    if (this.name.startsWith("match")) {
      this.uttLines = new ArrayList<SingleLine>();
      this.tSize = 1;
      this.lineIndex = 0;
    }
  }

  void clearBackground() {
    // println("clearing  " + this.name);
    this.s.beginDraw();
    // this.s.clear();
    this.s.background(222); 
    this.s.endDraw();
    // println("visible? " + this.visible);
  }


  void display(String name) {
    if (name.startsWith("match") && !this.reset) {
      displayMatch();
    }
    if (name.startsWith("title") && !this.reset) {
      makeTitle();
    }
    if (name.startsWith("info")) {
      displayInfo();
    }
    if (name.startsWith("article")) {
      displayMod(moderation);
    }
    if (name.startsWith("counter")) {
      displayCounter();
    }
    if (mFade && this.name.startsWith("match")) {
      fadeGraphics(this.s, this.name, 5);
    }
  }

  void fadeGraphics(PGraphics c, String name, int fadeAmount) {
    c.beginDraw();
    c.loadPixels();
    // iterate over pixels
    for (int i =0; i<c.pixels.length; i++) {
      // get alpha value
      alpha = (c.pixels[i] >> 24) & 0xFF ;
      // reduce alpha value
      alpha = max(0, alpha-fadeAmount);
      // assign color with new alpha-value
      c.pixels[i] = alpha<<24 | (c.pixels[i]) & 0xFFFFFF ;
    }
    c.updatePixels();
    c.endDraw();
    // println("fading   " + name );
  }

  void displayMatch() {
    this.s.beginDraw();
    // this.s.clear();
    this.s.background(222);
    for (SingleLine sl : uttLines) {
      this.s.textFont(this.font, this.tSize);
      this.s.fill(sl.col);
      this.s.text(sl.line, 10, sl.yPos);
    }
    this.s.endDraw();
  }

  void displayInfo() {
    String cat = translatedCats.getString(incomingCat);
    this.s.beginDraw();
    this.s.background(222);
    this.s.textFont(this.font, 15);
    this.s.fill(20, 200);
    this.s.rectMode(CORNER);
    // progress bar for remaining Timer
    this.s.text(incomingText + "\t     " + cat, 0, this.s.height/4, this.s.width, this.s.height);
    this.s.fill(189, 10, 10, 150);
    this.s.rect(0, 0, uttCount * prgIncrement, this.s.height/4);
    this.s.text("Wir sind im / We are in the \t\t - - " + currentPart + " - - \t \t  Teil / Part", 0, this.s.height *2/3, this.s.width, this.s.height);
    this.s.endDraw();
  }

  void displayMod(String type) {
    this.s.beginDraw();
    this.s.background (0, 0, 255);
    StringList moderation = makeList(type);
    String line = moderation.get(lineIndex % moderation.size());
    this.s.textFont(this.font, 18);
    this.s.textAlign(LEFT, TOP);
    this.s.fill(255);
    this.s.text(line, 0, 20, this.s.width, this.s.height);
    this.s.endDraw();
  }

  void displayCounter() {
    this.s.beginDraw();  
    this.s.background(222);
    this.s.textFont(this.font, 10);
    int rectWidth = 22; 
    int yPos = 30;
    for (int i=1; i<category_counter.size()+1; i++) {
      String category = cats[i-1];
      JSONObject cat_count = category_counter.getJSONObject(category);
      float limit = cat_count.getInt("limit");
      float rectCount = cat_count.getInt("count");
      this.s.rectMode(CENTER);
      this.s.textAlign(LEFT, TOP);
      color fillcol = findColor(category);
      int alpha = (fillcol >> 24) & 0xFF;
      alpha = 255;
      fillcol = alpha<<24 | fillcol & 0xFFFFFF ;
      // println("ypos  " + yPos *i);
      String cat = translatedCats.getString(category);
      this.s.fill(fillcol);
      this.s.text(cat, 10, (yPos +3) *i);
      this.s.noStroke();
      this.s.rectMode(CORNER);
      this.s.rect(80, yPos * i, rectCount *rectWidth, this.h/8);
      this.s.noFill();
      this.s.stroke(0);
      this.s.rect(80, yPos *i, limit*rectWidth, this.h/7);
    }
    this.s.endDraw();
  }

  void makeTitle() {
    this.s.beginDraw();
    // remove alpha color
    int alpha = (this.col >> 24) & 0xFF;
    alpha = 255;
    this.col = alpha<<24 | this.col & 0xFFFFFF ;
    this.s.background(this.col);
    this.s.textFont(this.font);
    this.s.textAlign(CENTER, CENTER);
    this.s.fill(20);
    this.s.text(this.message, this.w/2, this.h/2);
    this.s.endDraw();
  }

  void displaySculpture(String msg) {
    Area a = areas.findArea(incomingCat);
    a.sculptureText();
    // println("area name  " + a.name + "   pos  " + pos);
    this.s.beginDraw();
    this.s.textFont(this.font);
    this.s.textSize(20);
    this.s.textAlign(TOP, TOP);
    this.s.pushMatrix();
    this.s.translate(a.sC.x, a.sC.y);
    this.s.rotate(a.textAngle);
    this.s.fill(255);
    this.s.noStroke();
    println("text Ascent " + textAscent() + "text Width:  " + textWidth(msg) );
    this.s.rect(0, 0, textWidth(msg), textAscent() * 0.7);
    this.s.fill(a.col);
    this.s.text(msg, 0, 0);
    this.s.popMatrix();


    this.s.endDraw();
    a.textAngle += a.progressAngle;
  }
}

void buildSurfaces() {
  surfs = new ArrayList<SurfaceBase>();
  rauschSurf = new Rauschen("rausch", 0, 0, width, height, messageFont, true);
  incSurf = new Kinship("incoming", width/30, height/2, width *3/7, height/5, messageFont, false);
  matchSurf = new Kinship("matching", width *5/9, height/2, width *3/7, height/5, messageFont, false);
  //titleSurf1 = new Surface("titleIncoming", int(incSurf.pos.x), int(incSurf.pos.y-80), int(incSurf.w), 50, infoFont, false, "Dein Kommentar ähnelt...");
  //titleSurf2 =  new Surface("titleMatch", int(matchSurf.pos.x), int(matchSurf.pos.y-80), int(matchSurf.w), 50, infoFont, false, "...diesem hier");
  infoSurf = new Info("infoSurf", 0, height-height/12, width, height/12, infoFont, true);
  articleSurf = new Article("article", 0, 0, infoSurf.surf.width, infoSurf.surf.height, infoFont, false);
  sculptureSurf = new Sculpture("sculpture", 0, 0, width, height, infoFont, true);
  surfs.add(rauschSurf);
  surfs.add(incSurf);
  surfs.add(matchSurf);
  surfs.add(infoSurf);
  surfs.add(articleSurf);
  surfs.add(sculptureSurf);
}

StringList makeList(String type) {
  StringList list = new StringList();
  for (TableRow row : article.findRows(type, "type")) {
    String line = row.getString("utterance");
    list.append(line);
  }
  return list;
}
