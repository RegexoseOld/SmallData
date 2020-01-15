class PartsPosition {
  int key;
  PGraphics surface;
  float position;
  color bg;
  
  PartsPosition (int key, PGraphics surface, float position) {
    this.key = key;
    this.surface = surface;
    this.position = position;
    this.surface.background(bg);
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
}
