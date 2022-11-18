class Areas {
  ArrayList<Area> areas;
  RGroup shapeGrp;
  float areaAngle;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    areaAngle = 0.1;
    shapeGrp = new RGroup();
    makeAreas(cats);
    //shapeGrp.translate(500, 400);
    //shapeGrp.scale(0.7);
    //println("group width  " + shapeGrp.getWidth() + "   height   " + shapeGrp.getHeight());
  }

  void makeAreas(String[] cats) {
    RShape screenShape = new RShape();
    screenShape.addLineTo(width, 0);
    screenShape.addLineTo(width, height);
    screenShape.addLineTo(0, height);
    screenShape.addLineTo(0, 0);

    for (int i=0; i<5; i++) {
      String cat = cats[i];
      Area area = new Area(cat, areaAngle, screenShape);
      this.areas.add(area);
      shapeGrp.addElement(area.rS);
      areaAngle += TWO_PI/5;
    }
  }

  Area findArea(String cat) {
    Area newArea = null;
    for (Area a : this.areas) {
      if (a.name.equals(cat)) {
        newArea = a;
      }
    }
    return newArea;
  }
}

class Area {
  ArrayList<PVector> areaPos;
  PShape reset;
  RShape rS, screen, firstLine, secondLine;
  RShape nameShape;
  RPoint sC, centerOfArea, horizontal, txt, frst, scnd;
  RPoint[] points, handles, namePoints;
  RFont nameFont;
  String name; 
  color col; 
  float[] radi, nameAngles;
  float areaAngle, firstAngle, secondAngle, radius, progressAngle, textAngle;
  int transX, transY, resetCol, nameOffset;

  Area(String name, float angle, RShape screen) {
    this.name = name; 
    this.areaAngle = angle;
    this.screen = screen;
    this.sC = new RPoint(width/2, height/2);
    this.col = findColor(name); 
    this.rS = createRShape();
    this.handles = this.rS.getHandles();
    this.areaPos = new ArrayList<PVector>();
    this.reset = createShape();
    this.firstAngle = 0;
    this.progressAngle = 0.2;
    this.points = rS.getPoints();
    this.transX = 0;
    this.centerOfArea = this.rS.getCentroid();
    this.nameFont = new RFont("Courier New Bold Italic.ttf", height/18, RFont.CENTER);
    this.nameOffset = 0; // offset for the name of the area
    makeAngles();
    resetShape();
    createAreaPositions();
    makeNameShape();
  }

  RShape createRShape() {
    //Create triangle from screenCenter with a side length of radius r and an angle of TWO_PI/5
    // r is PVector(Width/2, height/2).mag
    rS = new RShape();
    this.horizontal = new RPoint(10, 0);
    //https://github.com/runemadsen/printing-code/blob/master/geomerative/beginshape/beginshape.pde
    radius = width;
    rS.addMoveTo(sC.x, sC.y);
    float x1 = sC.x + cos(this.areaAngle) * radius;
    float y1 = sC.y + sin(this.areaAngle) * radius;
    this.frst = new RPoint(x1, y1);
    this.firstLine = RShape.createLine(sC.x, sC.y, this.frst.x, this.frst.y);
    // copying to obtain angle
    rS.addLineTo(x1, y1);
    float x2 = sC.x + cos(this.areaAngle + TWO_PI/5) * radius;
    float y2 = sC.y + sin(this.areaAngle  + TWO_PI/5) * radius;
    this.scnd = new RPoint(x2, y2);
    this.secondLine = RShape.createLine(sC.x, sC.y, this.scnd.x, this.scnd.y);
    rS.addLineTo(x2, y2);
    RShape diff = rS.intersection(this.screen);
    return diff;
  }

  void makeNameShape() {
    this.nameShape = this.nameFont.toShape(this.name);
    this.namePoints = this.nameShape.getPoints();
    shapePositions();
    if (this.name.equals("insinuation")) {
      this.nameOffset = width/10;
    }
    //println("name   " + this.name + "   points   " + namePoints.length);
  }

  void shapePositions() {
    this.nameAngles = new float[this.namePoints.length]; // Liste mit dem spezifischen Winkel jedes Namepoints zum Mittelpunkt
    this.radi = new float[this.namePoints.length];
    for (int i=0; i<this.namePoints.length; i++) {
      this.nameAngles[i] = this.namePoints[i].angle(this.centerOfArea); // RG Vector von jedem namePoint zum Mittelpunkt
      this.radi[i] = this.namePoints[i].dist(this.centerOfArea); // Die distanz zwischen jedem namePoint im dem Mittelpunkt
    }
  }

  void makeAngles() {
    // hier wird für die Fläche der Area der erste und der letzte Winkel definiert
    // dient der Kalkulation der Textwinkel, die bei this.firstAngle beginnen und maximal bis this.secondAngle gehen
    RPoint frstCopy = new RPoint(this.frst);
    RPoint sCCopy = new RPoint(this.sC);
    sCCopy.sub(frstCopy);
    RPoint scndCopy = new RPoint(this.scnd);
    RPoint sCCopy2 = new RPoint(this.sC);
    sCCopy2.sub(scndCopy);
    if (this.frst.y <= height/2) {
      this.firstAngle = sCCopy.angle(this.horizontal) - PI;
    } else {
      this.firstAngle = - sCCopy.angle(this.horizontal) + PI;
    }
    if (this.scnd.y <= height/2) {
      this.secondAngle = sCCopy2.angle(this.horizontal) - PI;
    } else {
      this.secondAngle = - sCCopy2.angle(this.horizontal) + PI;
    }
    this.textAngle = this.firstAngle;
  }


  void createAreaPositions() {
    loadPixels();
    for (int x=0; x<width; x++) {
      for (int y=0; y<height; y++) {
        RPoint test = new RPoint(x, y);
        if (this.rS.contains(test)) {
          PVector pos = new PVector(x, y);
          this.areaPos.add(pos);
        }
      }
    }
  }

  void resetShape() {
    int a = 255;
    int r = 204;
    int g = 204;
    int b = 51;
    a = a << 24;
    r = r << 16;
    g = g << 8; 
    this.resetCol = (a | r | g | b);
    this.reset.beginShape();
    for (RPoint p : this.handles) {
      this.reset.vertex(p.x, p.y);
    }
    this.reset.endShape(CLOSE);
    this.reset.setFill(this.resetCol);
  }

  void changeAngle() {
    //println("name  " + name + "  textAngle  " + this.textAngle);
    if (this.textAngle > this.firstAngle + (TWO_PI/5)) {
      this.textAngle = this.firstAngle;
    } else {
      this.textAngle += this.progressAngle;
    }
  }

  void drawOutlines() {
    RPoint p = new RPoint();
    RPoint prv = new RPoint();
    // PVector firstPoint = new PVector(frst.x, frst.y);

    for (int i=0; i<this.handles.length; i++) {
      p = this.handles[i];
      if (i <=0) {
        prv = this.handles[this.handles.length -1];
      } else {
        prv = this.handles[i-1];
      }
      rauschSurf.areaOutlines(p, prv, this.centerOfArea, this.transX, this.col);
    }
  }

  void draw(PGraphics surf) {
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
    surf.beginDraw();
    // this.rS.draw();
    surf.stroke(0, 255, 0);
    surf.strokeWeight(10);
    surf.point(this.rS.getCentroid().x, this.rS.getCentroid().y);
    surf.textSize(30);
    surf.fill(this.col);
    surf.text(this.name, this.centerOfArea.x + this.transX, this.centerOfArea.y);
    surf.endDraw();
  }
}

class SculptElement {
  PImage element;
  Area area;
  PGraphics surf, elSurf;
  int alpha, w, h, textsize;
  PFont font;
  color col;
  String t, cat;
  float textangle, factor, first, last;
  PVector pos, rP;

  SculptElement(String _t, PFont _font, Area _a, int _w, int _h) {
    this.t = _t;
    this.w = _w;
    this.h = _h;
    this.font = _font;
    this.area = _a;
    this.col = this.area.col;
    this.textsize = 15;
    this.surf = createGraphics(_w, _h); 
    this.pos = new PVector(_w/2, _h/2);
    this.surf.smooth();
    this.alpha = 255;
    this.first = this.area.firstAngle;
    this.last = this.area.secondAngle;
    this.factor = 1.0;
    this.textangle = this.area.textAngle;
    makePImage();
  }

  void makePImage() {
    this.elSurf = createGraphics(int(textWidth(this.t)), int(textAscent() * 1.5));
    this.elSurf.smooth();
    this.elSurf.beginDraw();
    this.elSurf.background(255);
    this.elSurf.textAlign(TOP, TOP);
    this.elSurf.fill(this.col);
    this.elSurf.text(this.t, 0, 0);
    this.elSurf.endDraw();
    this.element = this.elSurf.get();
    this.element.resize(int(this.element.width * this.factor), int(this.element.height * this.factor));

    println("text angle  " + this.area.textAngle + "  element dimensions  " + element.width + ",  " + element.height);
  }


  void changeAlpha() {
    if (this.alpha >= 1) { 
      this.alpha -= 5;
      // println("alpha of " + this.t + "  is    " + this.alpha);
    }
  }
}
