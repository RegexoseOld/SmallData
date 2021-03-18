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
DisplayTD incomingUtt;
DisplayTD currentUtt;
Areas areas;
RShape area, newarea;
MessageHighlight mH; // Environment for growing Text display
Margin margin1; // works with mH to define when growing Text is visible
String[] fontlist;
String[] cats = {"praise", "dissence", "insinuation", "concession", "lecture"};
PFont messageFont;
JSONObject TD; // TrainingData is stored here
JSONObject oscTextIn; 
String incomingText, incomingCat; // a mock for incoming OSC text
color currentCol;
boolean messageLock = false; //turns true if incomingText matches an utt chosen in ScaledRotated.draw()
boolean messageIn = false; // background reset
boolean updateUtts = false;
boolean mFade;
StringDict shapeMapping = new StringDict(); // mapping to attribute categories to SVG filenames
PGraphics infoSurf;
int maxUtts = 1;
float prgIncrement;
int uttCount = 0; 
int currIdx;

void setup() {
  size(1500, 1200);
  TD = loadJSONObject("TrainingDataPelle01.json");
  fontlist = PFont.list();
  messageFont = createFont(fontlist[39], 50, true);
  oscP5 = new OscP5(this, 5040); //Audience Port
  loc = new NetAddress("127.0.0.1", 5040); // send to self
  RG.init(this);
  RG.ignoreStyles(false);
  RG.setPolygonizer(RG.ADAPTATIVE);
  areas = new Areas(cats);
  buildUtts(50);
  mH = new MessageHighlight(20, width/30, height/2, width *5/9, height/2, messageFont); // adapted from https://processing.org/examples/forceswithvectors.html
  margin1 = new Margin(mH.surf1.width, mH.surf1.height, 0.05);
  pickIncoming(); // pick first utt
  infoSurf = createGraphics(width, height/15);
  prgIncrement = 1.2;
  currIdx = 0;
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
  if (messageLock) {
    if (margin1.outMargin(mH)) {
      // println("out of margin:  " + mH.tWidth);
      PVector drag = margin1.drag(mH);
      mH.applyForce(drag);
      mH.update();
      mH.checkEdge(); 
      mH.displayText();
    } else {
      PVector gravity = new PVector(0, 0.6 * mH.mass);
      mH.applyForce(gravity);
      mH.update();
      mH.displayText();
    }
  }
  if (mFade) {
    PVector gravity = new PVector (0, - mH.mass);
    mH.applyForce(gravity);
    mH.update();
    mH.displayText();
  } 
  infoSurf.beginDraw();
  infoSurf.background(222);
  PFont font = createFont(fontlist[25], 20, true);
  infoSurf.textFont(font);
  infoSurf.fill(20, 200);
  infoSurf.rectMode(CORNER);
  // progress bar for remaining Timer
  infoSurf.text(incomingText + "\t     " + incomingCat, 0, infoSurf.height/4, infoSurf.width, infoSurf.height);
  fill(189, 10, 10, 150);
  infoSurf.rect(0, 0, uttCount * prgIncrement, infoSurf.height/4);
  infoSurf.endDraw();
  image(infoSurf, 0, height-infoSurf.height);
}

void createScheduleTimer(final float ms) {
  messageLock = true;
  t.schedule(new TimerTask() {
    public void run() {
      messageLock = false;
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
