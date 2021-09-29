import oscP5.*;  //<>//
import netP5.*;

OscP5 oscP5;
NetAddress loc;
JSONObject ip_config, color_scheme;
PFont font, font_bold;
AreaBase article;
Beat beat;
Parts parts;
SongStatus songstatus;
ArrayList<AreaBase> areas;
int bt;


void setup() {
  size(1000, 500);
  
  ip_config = loadJSONObject("../../../config/ip_config.json");
  String ip = ip_config.getString("audience");
  oscP5 = new OscP5(this, 5050); //Audience Port
  loc = new NetAddress(ip, 5050); // send to self
  int font_size = width/20;
  font = createFont("Helvetica", font_size, true);
  font_bold = createFont("Helvetica-Bold", font_size, true);
  makeColorScheme();
  makeAreas();
}

void draw() {
  for (AreaBase a : areas) {
    a.draw();
  }
}

void makeAreas() {
  areas = new ArrayList<AreaBase>();
  int y_spacing = height / 100;
  int x_spacing = width / 50;
  parts= new Parts("parts", x_spacing, y_spacing, width/6, height - 2 * y_spacing, font);
  beat = new Beat("beat", width/5, y_spacing, width / 6, height - 2 * y_spacing, font);
  songstatus = new SongStatus("status", width/2, 0, width/2, height, font);
  areas.add(beat);
  areas.add(parts);
  areas.add(songstatus);
}



void keyPressed() {
  if (key == 'n') {
    beat.beatnum +=1;
    beat.updateBeatnum(str(beat.beatnum), "False");
  }
}
