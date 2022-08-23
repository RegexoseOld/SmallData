class AreaBase {
  String name;
  int pos_x, pos_y, s_width, s_height;
  PGraphics surf;

  AreaBase(String _name, int pos_x, int pos_y, int s_width, int s_height) {
    this.name = _name;
    this.pos_x = pos_x;
    this.pos_y = pos_y;
    this.s_width = s_width;
    this.s_height = s_height;
    this.surf = createGraphics(this.s_width, this.s_height);
    this.surf.smooth();
  }
  void draw() {
    // println("drawing   " + this.name);
    image(this.surf, this.pos_x, this.pos_y);
  }
}

class Beat extends AreaBase {
  public int beatnum;
  color col;
  PFont font;

  Beat (String name, int pos_x, int pos_y, int s_width, int s_height, PFont font) {
    super(name, pos_x, pos_y, s_width, s_height);
    this.beatnum = 5;
    this.col = color(0, 255, 0);
    this.font = font;
  }

  public void updateBeatnum(String beatnum, String changeColor) {
    if (changeColor.equals("True")) {
      this.col = color(255, 0, 0);
    } else {
      this.col = color(0, 255, 0);
    }
    this.surf.beginDraw();
    this.surf.background(150);
    this.surf.textFont(this.font, 100);
    this.surf.fill(this.col);
    this.surf.textAlign(CENTER);
    this.surf.text(beatnum, this.surf.width/2, this.surf.height/2);
    this.surf.endDraw();
  }
}

class Parts extends AreaBase {
  String current, next;
  color col;
  PFont font;

  Parts (String name, int pos_x, int pos_y, int s_width, int s_height, PFont font) {
    super(name, pos_x, pos_y, s_width, s_height);
    this.surf = createGraphics(s_width, s_height);
    this.surf.smooth();
    this.col = color(0);
    this.font = font;
    updateParts("praise", "concession");
  }

  public void updateParts(String current, String next) {
    this.surf.beginDraw();
    this.surf.background(222);
    this.surf.textFont(this.font, 25);
    this.surf.fill(0);
    this.surf.textAlign(CENTER);
    this.surf.text("current part: \n" + current, this.surf.width/2, this.surf.height/4);
    this.surf.text("next part: \n" + next, this.surf.width/2, this.surf.height *3/4);
    this.surf.endDraw();
  }
}

class SongStatus extends AreaBase {
  PFont font;
  float rectHeight;
  JSONObject counter;

  SongStatus(String _name, int pos_x, int pos_y, int s_width, int s_height, PFont font) {
    super(_name, pos_x, pos_y, s_width, s_height);
    this.font = font;
    this.counter = new JSONObject();
  }
  public void updateStatus(JSONObject newCounter, boolean isLocked) {
    println("is locked  " + isLocked);

    this.counter = newCounter;
    // printArray(" Counter  " + this.counter);

    if (isLocked) {
      this.surf.beginDraw();
      this.surf.background(123);
      this.surf.textFont(this.font, 100);
      println("textfont 100");
      this.surf.textAlign(CENTER);
      this.surf.text("LOCKED", this.surf.width/2, this.surf.height/2);
      this.surf.endDraw();
    } else {

      float xPosBar = this.surf.width/6;
      float yPosBar = this.surf.height *4/5;
      float barWidth = this.surf.width/20;
      int increment = 30;
      int spacing = 50;
      String[] cats = (String[]) this.counter.keys().toArray(new String[this.counter.size()]);
      this.surf.beginDraw();
      this.surf.background(222);
      this.surf.textFont(this.font, width/60);
      println("textfont width/20  " + width/60);
      for (int i=0; i<cats.length; i++) {
        String cat = cats[i];
        println("current cat  " + cat);
        JSONObject value = this.counter.getJSONObject(cat);
        color col = color_scheme.getInt(cat);
        int count = value.getInt("count");
        int limit = value.getInt("limit");
        this.surf.fill(col);
        this.surf.noStroke();
        this.surf.rect(spacing + (xPosBar * i), yPosBar, barWidth, -count * increment);
        this.surf.stroke(255, 0, 0);
        this.surf.strokeWeight(3);
        this.surf.line(spacing + (xPosBar * i), yPosBar - (limit * increment), spacing + (xPosBar * i) + barWidth, yPosBar - (limit * increment));
        this.surf.pushMatrix();
        this.surf.translate(spacing + (xPosBar * i), yPosBar + 20);
        this.surf.rotate(QUARTER_PI);
        this.surf.fill(0);
        this.surf.textAlign(LEFT);
        this.surf.text(cat, 0, 0);
        this.surf.popMatrix();
      }
      this.surf.endDraw();
    }
  }
}

class Article extends AreaBase {
  PFont font;
  color col;
  StringList articleLines;
  Table artic;
  int indx;
  String currentLine;

  Article (String name, int pos_x, int pos_y, int s_width, int s_height, PFont font) {
    super(name, pos_x, pos_y, s_width, s_height);
    this.surf = createGraphics(s_width, s_height);
    this.surf.smooth();
    this.col = color(0);
    this.font = font;
    this.artic = loadTable("data/" + this.name, "header");
    this.articleLines = new StringList();
    makeLines("article");
    this.indx = 0;
  }

  void makeLines(String type) {
    for (TableRow row : artic.findRows(type, "type")) {
      String art_line = row.getString("utterance");
      this.articleLines.append(art_line);
    }
  }

  void updateLine() {
    this.surf.beginDraw();
    this.surf.background(180);
    this.surf.textFont(this.font, 12);
    this.surf.textAlign(LEFT, TOP);
    this.surf.fill(0);
    this.currentLine = this.articleLines.get(this.indx % this.articleLines.size());
    // println("performer current line " + this.currentLine);
    this.surf.text(this.currentLine, 0, 0);
    this.surf.endDraw();
    sendLine(); 
  }

  void sendLine() {
    OscMessage message = new OscMessage("/article");
    message.add(this.currentLine);
    oscP5.send(message, loc_send);
  }
}
