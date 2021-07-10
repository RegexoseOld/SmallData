class Areas {
  ArrayList<Area> areas;
  RGroup shapeGrp;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    shapeGrp = new RGroup();
    makeAreaShape(cats);
    shapeGrp.translate(500, 400);
    shapeGrp.scale(0.4);
    //println("group width  " + shapeGrp.getWidth() + "   height   " + shapeGrp.getHeight());
  }
  // eigentlich überflüssig ... 
  void makeAreaShape(String[] cats) {
    for (int i=0; i<5; i++) {
      String cat = cats[i];
      Area area = new Area(cat);
      this.areas.add(area);
      shapeGrp.addElement(area.rS);
      // println("area name  " + area.name + "  area width  " + area.rS.getWidth() + "  area X  " + area.rS.getX());
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
  PVector horizontal, centerOfArea, textStart, fromCenter;
  RShape rS, svgShape;
  RPoint txt, frst, scnd;
  RPoint[] points, handles;
  String name; 
  color col; 
  float firstAngle, maxAngle, radius, progressAngle, textAngle;
  int transX, transY;

  Area(String name) {
    this.name = name;
    this.col = attributeUtt(name); 
    this.rS = loadRShape(name);
    horizontal = new PVector(1, 0);
    this.handles = this.rS.getHandles();
    this.firstAngle = 0;
    this.progressAngle = 0.1;
    // println("name:   " + this.name + "   textStart:  " + this.textStart + "  handles0 x " + this.handles[0].x + "  y  " + this.handles[0].y);
    this.points = rS.getPoints();
    this.transX = 100;
    makeCenter(this.name);
    createHandles();
  }

  void makeCenter(String cat) {
    RPoint c = this.rS.getCenter();
    if (cat.equals("praise") || cat.equals("insinuation")) {
      this.transX = 0;
      this.transY = - 150;
    } else if (cat.equals("concession") || cat.equals("lecture")) {
      this.transX = 0;
      this.transY = 150;
    }
    this.centerOfArea = new PVector(c.x, c.y + this.transY);
  }

  void createHandles() {
    txt = this.handles[0];
    frst = this.handles[1];
    scnd = this.handles[2];
    this.textStart = new PVector(txt.x, txt.y);
    PVector firstPoint = new PVector(frst.x, frst.y);
    PVector secondPoint = new PVector(scnd.x, scnd.y);
    PVector firstLine = new PVector();
    //println("txt.x  " + txt.x + " txt y " + txt.y + "  textStart  " + this.textStart);
    // println("frst.x  " + frst.x + " frst y " + frst.y + "  first  " + firstPoint);
    //println("p.x  " + p.x + " p y " + p.y +  " prv.x  " + prv.x + " prv y " + prv.y);
    if (firstPoint.y < 0) {
      firstLine = PVector.sub( this.textStart, firstPoint);
      this.firstAngle = PVector.angleBetween(firstLine, horizontal) - PI;
    } else {
      firstLine = PVector.sub(firstPoint, this.textStart );
      this.firstAngle = PVector.angleBetween(horizontal, firstLine);
    }
    PVector secondLine= PVector.sub(secondPoint, this.textStart );
    println(horizontal + " firstLine  " + firstLine);
    println("name  " + name + "  textAngle  " + this.textAngle + "  maxAngle  " + this.maxAngle);
    // this.maxAngle = PVector.angleBetween(secondLine, horizontal);
    this.textAngle = this.firstAngle;
    println("name  " + name + "  initAngle  " + this.textAngle);
  }

  void sculptureText() {
    this.textAngle += this.progressAngle;
  }

  void drawOutlines() {
    RPoint p = this.handles[0];
    RPoint prv = this.handles[1];
    PVector firstPoint = new PVector(frst.x, frst.y);
    mainSurf.s.beginDraw();

    mainSurf.s.stroke(col);
    mainSurf.s.strokeWeight(10);
    if (vector) {
      mainSurf.s.point(p.x, p.y);
      mainSurf.s.point(prv.x, prv.y);
      mainSurf.s.text("start", p.x, p.y);
      mainSurf.s.text("first", prv.x, prv.y);
      mainSurf.s.strokeWeight(3);
      mainSurf.s.line(p.x, p.y, prv.x, prv.y);
    } else {
      mainSurf.s.point(this.textStart.x, this.textStart.y);
      mainSurf.s.point(firstPoint.x, firstPoint.y);
      mainSurf.s.text("start", this.textStart.x, this.textStart.y);
      mainSurf.s.text("first", firstPoint.x, firstPoint.y);
      mainSurf.s.strokeWeight(3);
      mainSurf.s.line(this.textStart.x, this.textStart.y, firstPoint.x, firstPoint.y);
    }
    mainSurf.s.endDraw();
  }

  void draw() {
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.centerOfArea.x, this.centerOfArea.y);
    textSize(12);
    text(this.name, this.centerOfArea.x + this.transX, this.centerOfArea.y);
  }
}
