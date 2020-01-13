
void build_surfaces(){
  music_surf = createGraphics(width*7/8, height*3/8);
  song_surf = createGraphics(music_surf.width*7/8, music_surf.height/4);
  current_part_surf = createGraphics(song_surf.width/10, song_surf.height);
  task_surf = createGraphics(width*7/16, height*3/8);
  next_surf = createGraphics(task_surf.width*7/8, task_surf.height/3);
  countdown_surf = createGraphics(task_surf.width*7/8, task_surf.height/3);
  draw_surface(music_surf, 195);
  draw_surface(task_surf, 195);
  draw_surface(song_surf, bg_color1);
  draw_surface(current_part_surf, bg_color1);
  draw_surface(next_surf, bg_color1);
  draw_surface(countdown_surf, bg_color1);
  song_surf.beginDraw();
  song_surf.image(current_part_surf, 0, 0);
  song_surf.endDraw();
  music_surf.beginDraw();
  music_surf.image(song_surf, music_surf.width/20, music_surf.height/3);
  music_surf.endDraw();
  task_build();
  text_surf = createGraphics(width*7/16, height*3/8);
  utt_surf = createGraphics(text_surf.width*2/3, text_surf.height/8);
  utt_surf.smooth();
  cat_surf = createGraphics(text_surf.width/3, utt_surf.height);
  cat_surf.smooth();
  draw_surface(text_surf, 195);
  
}

void draw_surface(PGraphics surface, int bg_color) {
  surface.beginDraw();
  surface.background(bg_color);
  surface.endDraw();
}

void update_music_surf(PGraphics surface, float position_x) {
  song_surf.beginDraw();
  song_surf.image(surface, position_x, 0);
  song_surf.endDraw();
  music_surf.beginDraw();
  music_surf.image(song_surf, music_surf.width/20, music_surf.height/3);
  music_surf.endDraw();
}
