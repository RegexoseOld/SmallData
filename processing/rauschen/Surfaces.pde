class Surface { //<>//
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
  int w, h, lineIndex;
  float  tSize;
  boolean visible, fade, sculpt;
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
    this.sculpt = true;
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
    this.s.beginDraw();
    this.s.background(222); 
    this.s.endDraw();
  }


  void display(String name) {
    if (name.startsWith("match")) {
      displayUtt();
    }
    if (name.startsWith("title")) {
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
    if (name.equals("sculpture") && this.sculpt) {
      displaySculpture();
      this.sculpt = false;
    }
     if (mFade && this.name.startsWith("match")) {
        fadeGraphics(this.s, this.name, 2);
      }
  }

  void fadeGraphics(PGraphics c, String name, int fadeAmount) {
    // println("fading   " + name);
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

  void displayUtt() {
    this.s.beginDraw();
    this.s.clear();
    for (SingleLine sl : uttLines) {
      this.s.textFont(this.font, this.tSize);
      this.s.fill(sl.col);
      this.s.text(sl.line, 10, sl.yPos);
    }
    this.s.endDraw();
  }

  void displayInfo() {
    this.s.beginDraw();
    this.s.background(222);
    this.s.textFont(this.font, 15);
    this.s.fill(20, 200);
    this.s.rectMode(CORNER);
    // progress bar for remaining Timer
    this.s.text(incomingText + "\t     " + incomingCat, 0, this.s.height/4, this.s.width, this.s.height);
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
      String cat = cats[i-1];
      JSONObject cat_count = category_counter.getJSONObject(cat);
      float limit = cat_count.getInt("limit");
      float rectCount = cat_count.getInt("count");
      this.s.rectMode(CENTER);
      this.s.textAlign(LEFT, TOP);
      color fillcol = attributeUtt(cat);
      int alpha = (fillcol >> 24) & 0xFF;
      alpha = 255;
      fillcol = alpha<<24 | fillcol & 0xFFFFFF ;
      // println("ypos  " + yPos *i);
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

  void displaySculpture() {
    Area a = areas.findArea(incomingCat);
    // RShape svg = a.svgShape;
    a.sculptureText();
    // println("area name  " + a.name + "   pos  " + pos);
    this.s.beginDraw();
    this.s.textFont(this.font);
    this.s.textAlign(CENTER, CENTER);
    this.s.fill(20);
    this.s.pushMatrix();
    this.s.stroke(a.col);
    this.s.strokeWeight(5);
    this.s.point(a.nextPoint.x, a.nextPoint.y);
    this.s.translate(a.fromCenter.x, a.fromCenter.y);
    this.s.rotate(a.textAngle);
    this.s.text(this.message, 0, 0);
    this.s.popMatrix();
    this.s.endDraw();
  }
}

void buildSurfaces() {
  mainSurf = new Surface("main", 0, 0, width, height, messageFont, true, "");
  incSurf = new Surface("matchSurf1", width/30, height/2, width *3/7, height/5, messageFont, false, incomingText);
  matchSurf = new Surface("matchSurf2", width *5/9, height/2, width *3/7, height/5, messageFont, false, "");
  titleSurf1 = new Surface("titleIncoming", int(incSurf.pos.x), int(incSurf.pos.y-80), int(incSurf.w), 50, infoFont, false, "Dein Kommentar ähnelt...");
  titleSurf2 =  new Surface("titleMatch", int(matchSurf.pos.x), int(matchSurf.pos.y-80), int(matchSurf.w), 50, infoFont, false, "...diesem hier");
  infoSurf = new Surface("infoSurf", 0, height-height/12, width, height/12, infoFont, true, incomingText);
  counterSurf = new Surface("counter", 0, height *3/4, width/8, height/6, infoFont, false, "categories");
  articleSurf = new Surface("article", 0, 0, infoSurf.s.width, infoSurf.s.height, infoFont, false, "");
  sculptureSurf = new Surface("sculpture", 0, 0, width, height, infoFont, false, incomingText);
  surfs[0] = mainSurf;
  surfs[1] = incSurf;
  surfs[2] = matchSurf;
  surfs[3] = titleSurf1;
  surfs[4] = titleSurf2;
  surfs[5] = infoSurf;
  surfs[6] = counterSurf;
  surfs[7] = articleSurf;
  surfs[8] = sculptureSurf;
}

StringList makeList(String type) {
  StringList list = new StringList();
  for (TableRow row : article.findRows(type, "type")) {
    String line = row.getString("utterance");
    list.append(line);
  }
  return list;
}
