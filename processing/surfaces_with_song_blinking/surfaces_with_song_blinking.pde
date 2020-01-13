import oscP5.*;
import netP5.*;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.Map.Entry;

OscP5 oscP5;
PGraphics music_surf, song_surf, part_surf, current_part_surf, previous_part_surf, task_surf, next_surf, countdown_surf, text_surf, utt_surf, cat_surf, utt_cat_surf;
boolean blinker;
TreeMap<String, PGraphics> utt_map;
HashMap<String, PartsPosition> part_map;
PartsPosition current_pp;
int index;
int position_y;
int bg_color1 = 222;
float pos_x = 0;

PFont Arial;
String message;
String cat;
String beat, hex_color;
int col;
String next_part_name = "Unknown";
String current_part_name = "Unknown";
String previous_part_name;
StringList part_list;

void setup() {
  size(900, 600);
  frameRate(25);
  utt_map = new TreeMap<String, PGraphics>();
  part_map = new HashMap<String, PartsPosition>(); 
  part_list = new StringList();
  index = 0;
  Arial = createFont("Arial", 15, true);
  build_surfaces();
  position_y = 0;
  blinker = false;
  /* start oscP5, listening for incoming messages at port 5500 */
  oscP5 = new OscP5(this, 5040);
  background(180);
  noLoop();
}

void draw() {
  image(text_surf, width/100, height/2);
  image(task_surf, (width/100 + task_surf.width +10), height/2);
  if (frameCount % 12 == 0) {
    blinker = !blinker; //<>//
    current_part_blink(current_pp);
    }
  image(music_surf, width/100, 0); //<>//
}
