class SurfaceBase { //<>// //<>//
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

class Kinship extends SurfaceBase {
  //class to show messages that are related to each other
  ArrayList<SingleLine> uttLines;
  float tSize;
  PGraphics titleSurf;
  color col;
  String title, currentMessage;
  boolean stopGrow, matched;

  Kinship(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.uttLines = new ArrayList<SingleLine>();
    this.titleSurf = createGraphics(_w, _h/10);
    this.tSize = 10.0;
    this.stopGrow = false;
  }

  void grow() {
    float gravity = 3 * tc.mass;
    tc.applyForce(gravity);
    tc.update(this.w);
    tc.checkEdge(this.w, this.font, this.tSize, this.currentMessage, this);
    this.visible = true;
  }

  void shrink() {
    float gravity = - 2 * tc.mass;
    tc.applyForce(gravity);
    tc.updateFade(this);
  }

  void matched(String msg, color c) {
    this.currentMessage = msg;
    this.col = c;
    this.matched = true;
  }

  void update() {
    if (this.matched) {
      if (!this.stopGrow) {
        grow();
      } else if (this.stopGrow && !activeTimer) {
        shrink();
      }
      this.surf.beginDraw();
      this.surf.background(222);
      for (SingleLine sl : this.uttLines) {
        this.surf.textFont(this.font, this.tSize);
        this.surf.fill(sl.col);
        this.surf.text(sl.line, 10, sl.yPos + 30);
      }
      makeTitle();
      this.surf.image(this.titleSurf, this.pos.x, this.pos.y);
      this.surf.endDraw();
    } else {
      clearSurf();
      //Todo  wo muss matchLock ausgeschaltet werden?
    }
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

  void clearSurf() {
    // println("clearSurf   " + this.name);
    this.surf.beginDraw();
    this.surf.background(222);
    this.surf.endDraw();
  }

  void setDark() {
    this.surf.beginDraw();
    for (SingleLine l : this.uttLines) {
      l.setDark();
    }
    this.surf.endDraw();
  }
}

class Article extends Kinship {
  String currentLine;
  int tSize;
  ArrayList<SingleLine> articleLines;

  Article(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible, int _tSize) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.currentLine = "";
    this.tSize = _tSize;
    this.articleLines = new ArrayList<SingleLine>();
  }

  void updateLine(String l) {
    this.surf.beginDraw();
    this.surf.background(180);
    this.surf.textFont(this.font);
    this.surf.textAlign(CENTER, CENTER);
    this.surf.fill(0);
    this.surf.text(l, 0, 0, this.surf.width, this.surf.height);
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
  ArrayList<SculptElement> elements, elements2;
  boolean canUpdate;

  Sculpture(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.elements = new ArrayList<SculptElement>();
    this.elements2 = new ArrayList<SculptElement>();
    this.canUpdate = true;
  }

  void addElements(String msg, String incomingCat) {
    Area a = areas.findArea(incomingCat);
    a.changeAngle(); // textAngle ändert sich, abhängig von der Area
    PVector angles = new PVector(a.firstAngle, a.secondAngle, a.textAngle); // für jedes neue Element werden die Angles festgeschrieben
    // todo einfach area übergeben und daraus die Angles und die color ableiten
    SculptElement sE = new SculptElement(msg, this.font, a, this.surf.width, this.surf.height);
    if (this.canUpdate) {
      elements.add(sE);
    } else if (!this.canUpdate) {
      // use elements2 when loop in updateSculpture is busy to avoid concurrency
      elements2.add(sE);
    }
  }

  void checkElements() {
    Iterator itr = this.elements.iterator();
    while (itr.hasNext()) {
      SculptElement e =  (SculptElement)itr.next();
      if (e.alpha <= 10) {
        itr.remove();
        break;
      }
    }
    // add elements of elements2 to elements and clear Array
    if (this.elements2.size() > 0) { 
      println("before adding elements2" + this.elements2.size() + "  to elements  " + this.elements.size());
      this.elements.addAll(this.elements2);
      println("after addingAll to elements  " + this.elements.size());
      this.elements2.clear();
    }
  }


  void updateSculpture() {
    checkElements();
    this.canUpdate = false;
    this.surf.beginDraw();
    this.surf.clear();
    for (SculptElement e : this.elements) {
      // println("area name  " + a.name + "   pos  " + pos);
      this.surf.pushMatrix(); 
      this.surf.translate(width/2, height/2);
      this.surf.rotate(e.current);
      this.surf.tint(255, e.alpha);
      this.surf.image(e.element, 0, 0);
      this.surf.popMatrix();
    }
    this.surf.endDraw();
    this.canUpdate = true;
  }
}

void buildSurfaces() {
  PFont articleFont = createFont("Courier", 30, true);
  surfs = new ArrayList<SurfaceBase>();
  rauschSurf = new Rauschen("rausch", 0, 0, width, height, messageFont, true);
  incSurf = new Kinship("incoming", width/30, height/2, width *3/7, height/3, messageFont, false);
  matchSurf = new Kinship("matching", width *5/9, height/2, width *3/7, height/3, messageFont, false);
  infoSurf = new Info("infoSurf", 0, height-height/12, width, height/12, infoFont, true);
  articleSurf = new Article("article", width /5, height/7, width *7/10, height *7/10, articleFont, true, 30);
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
