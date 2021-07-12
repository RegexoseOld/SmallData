class Areas {
  ArrayList<Area> areas;
  RGroup shapeGrp;
  float areaAngle;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    areaAngle = 0.0;
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
  PVector horizontal, textStart, fromCenter;
  RShape rS, screen;
  RPoint centerOfArea, txt, frst, scnd;
  RPoint[] points, handles;
  String name; 
  color col; 
  float areaAngle, firstAngle, maxAngle, radius, progressAngle, textAngle;
  int transX, transY;

  Area(String name, float angle, RShape screen) {
    this.name = name;
    this.areaAngle = angle;
    this.screen = screen;
    this.col = attributeUtt(name); 
    this.rS = createRShape();
    horizontal = new PVector(1, 0);
    this.handles = this.rS.getHandles();
    this.firstAngle = 0;
    this.progressAngle = 0.1;
    this.points = rS.getPoints();
    this.transX = 100;
    this.centerOfArea = this.rS.getCentroid();
    // createHandles();
  }

  RShape createRShape() {
    //Create triangle from screenCenter with a side length of radius r and an angle of TWO_PI/5
    // r is PVector(Width/2, height/2).mag
    rS = new RShape();
    //https://github.com/runemadsen/printing-code/blob/master/geomerative/beginshape/beginshape.pde
    radius = 2 * screenCenter.mag();
    rS.addMoveTo(screenCenter.x, screenCenter.y);
    float x1 = screenCenter.x + cos(this.areaAngle) * radius;
    float y1 = screenCenter.y + sin(this.areaAngle) * radius;
    rS.addLineTo(x1, y1);
    float x2 = screenCenter.x + cos(this.areaAngle + TWO_PI/5) * radius;
    float y2 = screenCenter.y + sin(this.areaAngle  + TWO_PI/5) * radius;
    rS.addLineTo(x2, y2);
    RShape diff = rS.intersection(this.screen);
    return diff;
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
    // this.centerOfArea = new PVector(c.x, c.y + this.transY);
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

    //angles depends on direction of Shape
    if (firstPoint.y < 0) {
      firstLine = PVector.sub( this.textStart, firstPoint);
      this.firstAngle = PVector.angleBetween(firstLine, horizontal) - PI;
    } else {
      firstLine = PVector.sub(firstPoint, this.textStart );
      this.firstAngle = PVector.angleBetween(horizontal, firstLine);
    }

    println(horizontal + " firstLine  " + firstLine);
    println("name  " + name + "  textAngle  " + this.textAngle + "  maxAngle  " + this.maxAngle);
    this.maxAngle = TWO_PI / 5;
    this.textAngle = this.firstAngle;
  }

  void sculptureText() {
    println("name  " + name + "  textAngle  " + this.textAngle);
    if (this.textAngle > this.firstAngle + this.maxAngle) {
      this.textAngle = this.firstAngle;
    } else {
      this.textAngle += this.progressAngle;
    }
  }

  void drawOutlines() {
    RPoint p = new RPoint();
    RPoint prv = new RPoint();
    // PVector firstPoint = new PVector(frst.x, frst.y);
    rauschSurf.s.beginDraw();
    for (int i=0; i<this.handles.length; i++) {
      p = this.handles[i];
      if (i <=0) {
        prv = this.handles[this.handles.length -1];
      } else {
        prv = this.handles[i-1];
      }
      // println("point x  " + p.x + "  y    " + p.y);
      rauschSurf.s.stroke(this.col);
      rauschSurf.s.strokeWeight(5);
      rauschSurf.s.line(p.x, p.y, prv.x, prv.y);
      rauschSurf.s.strokeWeight(15);
      rauschSurf.s.point(p.x, p.y);
      rauschSurf.s.strokeWeight(25);
      //rauschSurf.s.point(width/2, height/2);
    }
    rauschSurf.s.endDraw();
  }

  void draw() {
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.rS.getCentroid().x, this.rS.getCentroid().y);
    textSize(12);
    text(this.name, this.centerOfArea.x + this.transX, this.centerOfArea.y);
  }
}
