import oscP5.*;  //<>//
import netP5.*;

OscP5 oscP5;
NetAddress loc, loc_send;
JSONObject ip_config, color_scheme;
PFont font, font_bold;
Beat beat;
Parts parts;
Article article;
SongStatus songstatus;
ArrayList<AreaBase> areas;
int bt;


void setup() {
  size(1000, 500);
  ip_config = loadJSONObject("../../../config/ip_config.json");
  String ip = ip_config.getString("performer");
  String audience_ip = ip_config.getString("audience");
  oscP5 = new OscP5(this, 5050); //Audience Port
  loc = new NetAddress(ip, 5050); // send to self
  loc_send = new NetAddress(audience_ip, 5040);
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
  article = new Article("Moderation.tsv", width/16, 0, width *7/8, height/8, font);
  areas.add(beat);
  areas.add(parts);
  areas.add(songstatus);
  areas.add(article);
}



void keyReleased() {
  if (key == 'n') {
    article.indx += 1;
    article.updateLine();
  }
}
