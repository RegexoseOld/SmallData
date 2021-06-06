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
      Area area = new Area();
      area.constructWithName(cat, angle);
      this.areas.add(area);
      // println("area name  " + area.name + "  area width  " + area.rS.getWidth());
      angle += angIncrement;
    }
  }

  Area findArea(String cat) {
    Area newArea = new Area();
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
  RShape rS;
  RPoint[] points;
  String name; 
  color col; 
  float angle, angIncrement, radius, posX, posY;
  int num, transX;

  Area() {
    this.transX = 200;
  }

  void constructWithName(String name, float angle) {
    this.name = name;
    this.angle = angle;
    this.col = attributeUtt(name); 
    this.rS = loadRShape(name);    
    // this.rS.print();
    // println("name:   " + this.name + "   rS width:  " + this.rS.getWidth());
    this.rS.scale(50);
    this.points = rS.getPoints();
  }

  PShape makeShape(String name) {
    println("making   " + name);
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
  
    // println(" draw name:   " + this.name + "   rS origwidth:  " + this.rS.getOrigWidth() + "   rS newwidth:  " + this.rS.getWidth());
   
    this.rS.draw();
    stroke(0, 255, 0);
    strokeWeight(10);
    point(this.rS.getCenter().x + transX, this.rS.getCenter().y);
    text(this.name, this.rS.getCenter().x + transX, this.rS.getCenter().y); 
  }
}
