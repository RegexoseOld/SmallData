import java.util.Timer;   //<>//
import java.util.TimerTask;
import java.util.Map;
import java.util.List;
import java.util.Iterator; 
import geomerative.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress loc;

final Timer t = new Timer();
ArrayList<DisplayTD> utts = new ArrayList<DisplayTD>(); // list with all the Text Objects
Surface incSurf, matchSurf, titleSurf1, titleSurf2, infoSurf;
Surface[] surfs;
DisplayTD incomingUtt;
DisplayTD currentUtt;
Areas areas;
RShape area, newarea;
MessageHighlight mH; // Environment for growing Text display
Margin margin1; // works with mH to define when growing Text is visible
String[] fontlist;
String[] cats = {"praise", "dissence", "insinuation", "concession", "lecture"};
PFont messageFont, infoFont;
JSONObject TD; // TrainingData is stored here
JSONObject oscTextIn; 
String incomingText, incomingCat; // a mock for incoming OSC text
color currentCol;
boolean messageLock = false; //turns true if incomingText matches an utt chosen in ScaledRotated.draw()
boolean messageIn = false; // background reset
boolean updateUtts = false;
boolean mFade;
StringDict shapeMapping = new StringDict(); // mapping to attribute categories to SVG filenames
int maxUtts = 1;
float prgIncrement;
int uttCount = 0; 

void setup() {
  size(1500, 1200);
  TD = loadJSONObject("TrainingDataPelle01.json");
  surfs = new Surface[5];
  fontlist = PFont.list();
  messageFont = createFont(fontlist[39], 30, true);
  infoFont = createFont(fontlist[25], 20, true);
  oscP5 = new OscP5(this, 5040); //Audience Port
  loc = new NetAddress("127.0.0.1", 5040); // send to self
  RG.init(this);
  RG.ignoreStyles(false);
  RG.setPolygonizer(RG.ADAPTATIVE);
  areas = new Areas(cats);
  buildUtts(50);
  mH = new MessageHighlight(40, messageFont); // adapted from https://processing.org/examples/forceswithvectors.html
  margin1 = new Margin(incSurf.w, incSurf.h, 0.05);
  pickIncoming(); // pick first utt
  prgIncrement = 1.2;
  mFade = false;
  frameRate(20);
}

void draw() {
  // if (frameCount%40 == 0) {pickIncoming();} automatische messages werden ausgesucht
  if (messageIn) {
    background(222);
    messageIn = !messageIn;
  }

  for (int x=0; x<utts.size(); x++) {
    DisplayTD utt = utts.get(x);
    utt.draw();
    currentCol = utt.shapeColor;
    utt.matchInput(incomingText);

  }
  
  for (Surface surf : surfs) {
    surf.display(surf.name);
    image(surf.s, surf.pos.x, surf.pos.y);
  }
  
  if (messageLock) {
    if (margin1.outMargin(mH)) {
      // println("out of margin:  " + mH.tWidth);
      float drag = margin1.drag(mH);
      mH.applyForce(drag);
      mH.update();
      mH.checkEdge(); 
      mH.displayText();
    } else {
      float gravity = 2 * mH.mass;
      mH.applyForce(gravity);
      mH.update();
      mH.displayText();
    }
  }
  if (mFade) {
    float gravity = - mH.mass *2;
    mH.applyForce(gravity);
    mH.update();
    mH.displayText();
  } 
}

void createScheduleTimer(final float ms) {
  messageLock = true;
  t.schedule(new TimerTask() {
    public void run() {
      mFade = true;
    }
  }
  , (long) (ms));
}

void buildUtts(int amount) {
  shapeMapping.set("praise", "knacks01.svg");
  shapeMapping.set("dissence", "knacks02.svg");
  shapeMapping.set("insinuation", "knacks03.svg");
  shapeMapping.set("concession", "knacks04.svg");
  shapeMapping.set("lecture", "knacks05.svg");
  for (int i=0; i<amount; i++) {
    int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(index));
    String utterance = row.getString("utterance");
    String category = row.getString("category").toLowerCase();
    PShape shape = loadShape(shapeMapping.get(category));
    DisplayTD utt = new DisplayTD(i, utterance, category, shape, 5, false);
    utts.add(utt);
  }
}
