void song_build(StringList parts) {
  int partCounter= 0;
  for (String part : parts) {
    // println(part);
    part_surf = createGraphics(song_surf.width/parts.size(), song_surf.height);
    part_surf.beginDraw();
    part_surf.textFont(Arial, 10);
    part_surf.textAlign(CENTER);
    part_surf.fill(0);
    part_surf.text(part, part_surf.width/2, part_surf.height/2);
    part_surf.noFill();
    part_surf.rect(0, 0, part_surf.width -1, part_surf.height -1);
    part_surf.endDraw();
    song_surf.beginDraw();
    song_surf.image(part_surf, pos_x, 0);
    song_surf.endDraw();
    PartsPosition pp = new PartsPosition(partCounter, part, part_surf, pos_x);
    part_map.put(part, pp);
    pos_x += part_surf.width;
    partCounter += 1;
  }
  music_surf.beginDraw();
  music_surf.image(song_surf, music_surf.width/20, music_surf.height/3);
  music_surf.endDraw();
  song_update("Hippie-Solo");
}

void song_update(String new_part_name) {
  // println("previous:   " + previous_part_name);
  for (HashMap.Entry<String, PartsPosition> entry : part_map.entrySet()) {
    String part_key = entry.getKey();
    PartsPosition pp = entry.getValue();
    PGraphics part_surf = pp.getSurface();
    float position = pp.getPosition();
    if (part_key.equals(new_part_name)){
      current_pp = pp;
      // println("currentpp name:   " + current_pp.name);
      current_part_surf = part_surf;
      current_part_name = part_key;
      pos_x = position;
      previous_part_name = new_part_name;
      PartsPosition p_previous = part_map.get(previous_part_name);
      previous_part_surf = p_previous.getSurface();
      // blinker = true;
      // float previous_position = p_previous.getPosition();
      // reset_surf(previous_part_surf, previous_position);
    } 
  }
}

void current_part_blink(PartsPosition pp) {
  if (blinker) {
    pp.changeBg(true);
  }  else {
    pp.changeBg(false);
  } 
  update_music_surf(pp.surface, pos_x);
}
