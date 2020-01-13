void task_build() {
  next_surf.beginDraw();
  next_surf.textFont(Arial, 14);
  next_surf.fill(0);
  next_surf.textAlign(CENTER);
  next_surf.text("next part is: " + next_part_name, next_surf.width/2, next_surf.height/2);
  next_surf.endDraw();
  task_surf.beginDraw();
  task_surf.image(next_surf, task_surf.width/18, task_surf.height/8);
  task_surf.image(countdown_surf, task_surf.width/18, task_surf.height*5/8);
  task_surf.endDraw();
}

void task_update(String current, String next) {
  // current_part_name = current;
  // next_part_name = next;
  next_surf.beginDraw();
  next_surf.background(222);
  next_surf.textFont(Arial, 14);
  next_surf.fill(0);
  next_surf.textAlign(CENTER);
  next_surf.text(("current part is: " + current), next_surf.width/2, next_surf.height/4);
  next_surf.text(("next part is: " + next), next_surf.width/2, next_surf.height*3/4);
  next_surf.endDraw();
  task_surf.beginDraw();
  task_surf.image(next_surf, task_surf.width/18, task_surf.height/8);
  task_surf.endDraw();
}

void beat_update(String beat, int c) {
  countdown_surf.beginDraw();
  countdown_surf.background(222);
  countdown_surf.textFont(Arial, 40);
  // see https://forum.processing.org/two/discussion/23953/convert-a-string-to-a-hexidecimal
  // countdown_surf.fill(0xff000000 | c);
  countdown_surf.fill(c);

  countdown_surf.textAlign(CENTER, CENTER);
  countdown_surf.text(beat, countdown_surf.width/2, countdown_surf.height/2);
  countdown_surf.endDraw();
  task_surf.beginDraw();
  task_surf.image(countdown_surf, task_surf.width/18, task_surf.height*5/8);
  task_surf.endDraw();
}
