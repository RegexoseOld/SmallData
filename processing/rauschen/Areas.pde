class Areas {
  ArrayList<Area> areas;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    makeAreaShape(cats);
  }

  void makeAreaShape(String[] cats) {
    float angIncrement = TWO_PI/ cats.length;
    float angle = 0;
    for (int i=0; i<5; i++) {
      String cat = cats[i];
      Area area = new Area(cat, angle);
      area.svgShape = loadRShape("knacks0" + (i+1));
      area.points = area.svgShape.getPoints();
      this.areas.add(area);
      println("area name  " + area.name + "  area width  " + area.rS.getWidth() + "  area X  " + area.rS.getX());
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
  PShape aShape; 
  PVector center;
  RShape rS, svgShape;
  RPoint[] points;
  String name; 
  color col; 
  float angle, angIncrement, radius, posX, posY;
  int num, transX, transY;

  Area(String name, float angle) {
    this.name = name;
    this.angle = angle;
    this.col = attributeUtt(name); 
    this.rS = loadRShape(name);  
    this.rS.scale(0.9);
    // this.rS.print();
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

  //PShape makeShape(String name) {
  //  println("making   " + name);
  //  PShape s = createShape();
  //  s.beginShape();
  //  s.vertex(width/2, height/2);
  //  this.posX = width/2 + cos(this.angle) * this.radius;
  //  this.posY = height/2 + sin(this.angle) * this.radius;
  //  s.vertex(this.posX, this.posY);
  //  this.angle += this.angIncrement;
  //  this.posX = width/2 + cos(this.angle)* this.radius;
  //  this.posY = height/2 + sin(this.angle)* this.radius;
  //  s.vertex(this.posX, this.posY);
  //  s.endShape(CLOSE);
  //  s.setFill(this.col);
  //  return s;
  //}

  void draw() {
    // translate(this.transX, 0);
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.center.x, this.center.y);
    text(this.name, this.center.x + this.transX, this.center.y);
  }
}
