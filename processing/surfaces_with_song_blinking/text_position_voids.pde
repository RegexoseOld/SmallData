void display_text(PGraphics surface) {
  int dict_size = 6;
  if (utt_map.size() >= dict_size) {
    int first_index = index - dict_size;
    String f_index = str(first_index);
    utt_map.remove(f_index);
    String sindex = str(index);
    utt_map.put(sindex, surface);
    /* println("keys: "+hm.entrySet()); */
  } else {
    String sindex = str(index);
    utt_map.put(sindex, surface);
  }
  index += 1;
}

void position_utts(String message, String cat) {
  /* calc_height(utt_surf, Arial, message); */
  text_surf.beginDraw();
  text_surf.background(195);
  utt_cat_surf = createGraphics(text_surf.width, utt_surf.height);
  draw_text1(utt_surf, message);
  draw_text1(cat_surf, cat);
  utt_cat_surf.beginDraw();
  utt_cat_surf.image(utt_surf, 0 , 0);
  utt_cat_surf.image(cat_surf, utt_surf.width +3 , 0);
  utt_cat_surf.endDraw();
  display_text(utt_cat_surf);
  position_y = 0;
  for (Entry<String, PGraphics> me : utt_map.descendingMap().entrySet()) {
      text_surf.image(me.getValue(), 0, position_y);
      position_y += me.getValue().height;
  }
  text_surf.endDraw();
}

void render_tasks() {
  task_surf.beginDraw();
  task_surf.endDraw();
}

void draw_text1(PGraphics surface, String text) {
  surface.beginDraw();
  surface.clear();
  surface.fill(0);
  surface.background(222);
  surface.textFont(Arial);
  surface.text(text, 0, 0, surface.width, surface.height);
  surface.endDraw();
}
/*
void draw_text_big(PGraphics surface, String text) {
  surface.beginDraw();
  surface.fill(0);
  surface.textFont(Arial, 30);
  surface.text(text, 0, 0, surface.width, surface.height);
  surface.endDraw();
} */
  
