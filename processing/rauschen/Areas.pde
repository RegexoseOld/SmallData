class Areas {
  ArrayList<Area> areas;
  RGroup shapeGrp;
  float areaAngle;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    areaAngle = 0;
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
  PVector textStart, fromCenter;
  RShape rS, screen, firstLine, secondLine;
  RPoint sC, centerOfArea, horizontal, txt, frst, scnd;
  RPoint[] points, handles;
  String name; 
  color col; 
  float areaAngle, firstAngle, secondAngle, radius, progressAngle, textAngle;
  int transX, transY;

  Area(String name, float angle, RShape screen) {
    this.name = name;
    this.areaAngle = angle;
    this.screen = screen;
    this.sC = new RPoint(width/2, height/2);
    this.col = attributeUtt(name); 
    this.rS = createRShape();
    this.handles = this.rS.getHandles();
    this.firstAngle = 0;
    this.progressAngle = 0.1;
    this.points = rS.getPoints();
    this.transX = 100;
    this.centerOfArea = this.rS.getCentroid();
    makeAngles();
    drawOutlines();
    // createHandles();
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
    // println("diff shape  " + this.name + "  has  " + diff.paths[0].getPoints().length + "  points");
    return diff;
  }

  void makeAngles() {
    RPoint frstCopy = new RPoint(this.frst);
    RPoint sCCopy = new RPoint(this.sC);
    sCCopy.sub(frstCopy);
    RPoint scndCopy = new RPoint(this.scnd);
    RPoint sCCopy2 = new RPoint(this.sC);
    sCCopy2.sub(scndCopy);
    if (frstCopy.y < height/2) {
      this.firstAngle = sCCopy.angle(this.horizontal) - PI;
    } else {
      this.firstAngle = sCCopy.angle(this.horizontal);
    }
    println("name  " + this.name + "  1. angle  " + this.firstAngle);

    this.secondAngle = sCCopy2.angle(this.horizontal);
    // println("2. angle  " + this.secondAngle);
    this.textAngle = this.firstAngle;
  }

  //void makeCenter(String cat) {
  //  RPoint c = this.rS.getCenter();
  //  if (cat.equals("praise") || cat.equals("insinuation")) {
  //    this.transX = 0;
  //    this.transY = - 150;
  //  } else if (cat.equals("concession") || cat.equals("lecture")) {
  //    this.transX = 0;
  //    this.transY = 150;
  //  }
  //  // this.centerOfArea = new PVector(c.x, c.y + this.transY);
  //}

  //void createHandles() {

  //  txt = this.handles[0];
  //  this.frst = this.handles[1];
  //  this.scnd = this.handles[this.handles.length-1];
  //  this.textStart = new PVector(txt.x, txt.y);
  //  PVector firstPoint = new PVector(frst.x, frst.y);
  //  PVector secondPoint = new PVector(scnd.x, scnd.y);


  //  //println("txt.x  " + txt.x + " txt y " + txt.y + "  textStart  " + this.textStart);
  //  // println("frst.x  " + frst.x + " frst y " + frst.y + "  first  " + firstPoint);
  //  //println("p.x  " + p.x + " p y " + p.y +  " prv.x  " + prv.x + " prv y " + prv.y);

  //  //angles depends on direction of Shape
  //  if (firstPoint.y < 0) {
  //    firstLine = PVector.sub(this.textStart, firstPoint);
  //    secondLine = PVector.sub(this.textStart, secondPoint);
  //    this.firstAngle = PVector.angleBetween(firstLine, horizontal) - PI;
  //  } else {
  //    firstLine = PVector.sub(firstPoint, this.textStart );
  //    secondLine = PVector.sub(secondPoint, this.textStart);
  //    this.firstAngle = PVector.angleBetween(horizontal, firstLine);
  //  }

  //  println(horizontal + " firstLine  " + firstLine);
  //  println("name  " + name + "  textAngle  " + this.textAngle + "  maxAngle  " + this.maxAngle);
  //  this.maxAngle = TWO_PI / 5;
  //  this.textAngle = this.firstAngle;
  //}

  void sculptureText() {
    println("name  " + name + "  textAngle  " + this.textAngle);
    if (this.textAngle > this.firstAngle + this.secondAngle) {
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
      rauschSurf.s.fill(this.col);
      rauschSurf.s.textSize(30);
      rauschSurf.s.text(this.name, this.centerOfArea.x + this.transX, this.centerOfArea.y);
      //rauschSurf.s.point(width/2, height/2);
    }
    rauschSurf.s.endDraw();
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
