class Areas {
  ArrayList<Area> areas;
  float angle;

  Areas(String[] cats) {
    this.areas = new ArrayList<Area>();
    this.angle = 0;
    makeAreaShape(cats);
  }
  
  void makeAreaShape(String[] cats) {
    float angIncrement = TWO_PI/ cats.length;
    for (int i=0; i<5; i++) {
      String cat = cats[i];
      Area area = new Area(cat);
      this.areas.add(area);
      this.angle += angIncrement;
    }
  }

  RShape findArea(String cat) {
    RShape rS = RG.loadShape("data/"+ cat +".svg");
    return rS;
  }
}

class Area {
  PShape aShape; 
  RShape rS;
  RPoint[] points;
  String name; 
  color col; 
  float angle, angIncrement, radius, posX, posY;
  int num;

  Area(String name) {
    this.name = name; 
    this.col = attributeUtt(this.name); 
    this.rS = RG.loadShape("data/"+ name +".svg"); //<>//
    this.points = rS.getPoints();
    // println("loaded .... " + name);
  }

  PShape makeShape() {
    println("making   " + this.name);
    PShape s = createShape();
    s.beginShape();
    s.vertex(width/2, height/2);
    this.posX = width/2 + cos(this.angle) * this.radius;
    this.posY = height/2 + sin(this.angle) * this.radius;
    s.vertex(this.posX, this.posY);
    this.angle += this.angIncrement;
    this.posX = width/2 + cos(this.angle)* this.radius;
    this.posY = height/2 + sin(this.angle)* this.radius;
    s.vertex(this.posX, this.posY);
    s.endShape(CLOSE);
    s.setFill(this.col);
    return s;
  }

  void draw() {
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.rS.getCenter().x, this.rS.getCenter().y);
    text(this.name,this.rS.getCenter().x, this.rS.getCenter().y); 
  }
}
