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

  void makeAreaShape(String[] cats) {
    float angIncrement = TWO_PI/ cats.length;
    float angle = 0;
    for (int i=0; i<5; i++) {
      String cat = cats[i];
      Area area = new Area(cat, angle);
      this.areas.add(area);
      shapeGrp.addElement(area.rS);
      // println("area name  " + area.name + "  area width  " + area.rS.getWidth() + "  area X  " + area.rS.getX());
      angle += angIncrement;
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
  PVector center, fromCenter;
  RShape rS, svgShape;
  RPoint nextPoint;
  RPoint[] points;
  String name; 
  color col; 
  float angle, angIncrement, radius, progressAngle, textAngle;
  int transX, transY, pointIndex;

  Area(String name, float angle) {
    this.name = name;
    this.angle = angle;
    this.col = attributeUtt(name); 
    this.rS = loadRShape(name);
    //this.rS.scale(0.8);
    //this.rS.translate(400, 50);
    //this.rS.rotate(-0.1);
    progressAngle = 0;
    pointIndex = 0;
    // println("name:   " + this.name + "   rS width:  " + this.rS.getWidth());
    this.points = rS.getPoints();
    this.transX = 100;
    makeCenter(this.name);
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
    this.center = new PVector(c.x, c.y + this.transY);
  }

  void sculptureText() {
    nextPoint = this.points[(pointIndex % this.points.length)];
    PVector nP = new PVector(nextPoint.x, nextPoint.y);
    fromCenter = PVector.sub(screenCenter, nP);
    this.textAngle = PVector.angleBetween(new PVector(1, 0), fromCenter) - HALF_PI;
    pointIndex +=1;
    println("pointindex  " + pointIndex);
    // progressAngle += 0.01;
  }

  void drawOutlines() {
    mainSurf.s.beginDraw();
    RPoint[] box = this.rS.getBoundsPoints();
    RRectangle box2 = this.rS.getBounds();
    for (RPoint p : box) {
      mainSurf.s.stroke(col);
      mainSurf.s.strokeWeight(10);
      mainSurf.s.point(p.x, p.y);
    }
    mainSurf.s.endDraw();
  }

  void draw() {
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.center.x, this.center.y);
    textSize(12);
    text(this.name, this.center.x + this.transX, this.center.y);
  }
}
