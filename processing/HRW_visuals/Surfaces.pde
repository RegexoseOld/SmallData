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
  void clearSurf() {
    println("clearSurf   " + this.name);
    this.surf.beginDraw();
    this.surf.clear();
    this.surf.endDraw();
  }
}

class Article extends SurfaceBase {
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
  int svgCount;
  RShape[] rays;
  float[] angles;
  float[] radi;
  int offset;

  Rauschen(String name, int _x, int _y, int _w, int _h, PFont _font, boolean _visible) {
    super(name, _x, _y, _w, _h, _font, _visible);
    this.svgCount= 0;
    this.surf.beginDraw();
    this.surf.background(222);
    this.surf.endDraw();
  }
  void updateDisplay(PShape s, Area area, float size, float a, color col ) {
    RPoint center = area.centerOfArea;
    RShape pos = area.nameShape;
    RPoint[] pts = area.namePoints;
    float[] nAng = area.nameAngles;
    float[] radi = area.radi;
    float x1 = 0;
    float y1 = 0;
    int len = pos.getPoints().length;
    this.svgCount +=1;
    RPoint p = new RPoint();
    //println("svg count " + ths.svgCount);
    if (this.svgCount < 7000) {
      int ind = int(random(len));
      p = pts[ind];
      float angle = nAng[ind];
      // println("dist  " + dist(center.x, center.y, p.x, p.y));

      x1 = (center.x + p.x ) + cos(angle) ;
      y1 = (center.y + p.y) + sin(angle) ;
    }  else {
      area.nameOffset = 0;
      int ind = int(random(area.areaPos.size()));
      PVector pp = area.areaPos.get(ind);
      x1 = pp.x;
      y1 = pp.y;
    }
    this.surf.beginDraw();
    this.surf.noStroke();
    this.surf.pushMatrix();
    this.surf.translate(x1 + area.nameOffset, y1);
    this.surf.rotate(a);
    this.surf.fill(col);
    this.surf.shape(s, 0, 0, size, size) ;
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

  void updateInfo() {
    String cat = translatedCats.getString(incomingCat); 
    this.surf.beginDraw(); 
    this.surf.background(200); 
    this.surf.textFont(this.font, width/50); 
    this.surf.textAlign(CENTER);
    this.surf.fill(20, 200); 
    //this.surf.rectMode(CORNER); 
    //// progress bar for remaining Timer
    //// this.surf.text(incomingText + "\t     " + cat, 0, this.surf.height/4, this.surf.width, this.surf.height);
    //this.surf.fill(189, 10, 10, 150); 
    //this.surf.rect(0, 0, uttCount * prgIncrement, this.surf.height/4); 
    this.surf.text("kommentieren Sie auf - - Meinungsorgel.de", 0, 0, this.surf.width, this.surf.height); 
    this.surf.endDraw(); 
    println("info updated with  " + cat);
  }
  
  void displayName(Area a){
  
    this.surf.beginDraw(); 
    this.surf.fill(100, 100);
    this.surf.textFont(areaFont);
    this.surf.text(a.name, a.centerOfArea.x - a.nameOffset, a.centerOfArea.y);
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
    // PVector angles = new PVector(a.firstAngle, a.secondAngle, a.textAngle); // für jedes neue Element werden die Angles festgeschrieben
    // todo einfach area übergeben und daraus die Angles und die color ableiten
    SculptElement sE = new SculptElement(msg, this.font, a, this.surf.width, this.surf.height); 
    
    if (this.canUpdate) {
      elements.add(sE);
    } else {
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
  areaSurf = new Info("areaNames", 0, 0, width,height, areaFont, true);
  rauschSurf = new Rauschen("rausch", 0, 0, width, height, messageFont, true); 
  infoSurf = new Info("infoSurf", width *3/5, height/30, width/3, height/12, areaFont, true); 
  articleSurf = new Article("article", width /5, height/7, width *7/10, height *7/10, articleFont, true, 30); 
  sculptureSurf = new Sculpture("sculpture", 0, 0, width, height, infoFont, true); 
  surfs.add(rauschSurf); 
  surfs.add(areaSurf);
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
