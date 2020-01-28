class PartsPosition {
  int key;
  String name;
  PGraphics surface;
  float position;
  color bg;
  
  PartsPosition (int key, String tempName, PGraphics surface, float position) {
    this.key = key;
    this.name = tempName;
    this.surface = surface;
    this.position = position;
  }
  public PGraphics getSurface() {
    return surface;
  }
  public float getPosition() {
    return position;
  }
  public int getKey() {
    return key;
  }
  
  void changeBg(boolean boo, String currentName) {
      if (boo) {
        this.surface.beginDraw();
        this.surface.background(250); //<>// //<>//
        this.surface.textFont(Arial, 10);
        this.surface.textAlign(CENTER);
        this.surface.fill(20);
        this.surface.text(currentName, this.surface.width/2, this.surface.height/2);
        this.surface.noFill();
        this.surface.rect(0, 0, this.surface.width -1, this.surface.height -1);
        this.surface.endDraw();
    } else {
        this.surface.beginDraw();
        this.surface.background(222);
        this.surface.textFont(Arial, 10);
        this.surface.textAlign(CENTER);
        this.surface.fill(20);
        this.surface.text(currentName, this.surface.width/2, this.surface.height/2);
        this.surface.noFill();
        this.surface.rect(0, 0, this.surface.width -1, this.surface.height -1);
        this.surface.endDraw();
     }
     update_music_surf(this.surface, this.position);
  }
}
