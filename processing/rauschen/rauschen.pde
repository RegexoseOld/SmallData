import java.util.Timer;
import java.util.TimerTask;
import java.util.Map;
import java.util.Iterator; 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress loc;


final Timer t = new Timer();
ArrayList<DisplayTD> utts = new ArrayList<DisplayTD>(); // list with all the Text Objects
MessageHighlight mH; // Environment for growing Text display
Margin margin1; // works with mH to define when growing Text is visible
String[] fontlist;
PFont messageFont;
JSONObject TD; // TrainingData is stored here
JSONObject incomingUtt; 
String incomingText, incomingCat; // a mock for incoming OSC text
boolean messageLock = false; //turns true if incomingText matches an utt chosen in ScaledRotated.draw()
boolean messageIn = false;
StringDict shapeMapping = new StringDict(); // mapping to attribute categories to SVG filenames
PGraphics infoSurf;
int maxUtts = 1;
float prgIncrement;
int uttCount = 0; 

void setup(){
  size(1500, 1200);
  TD = loadJSONObject("TrainingDataPelle01.json"); //<>//
  fontlist = PFont.list();
  messageFont = createFont(fontlist[39], 50, true);
  oscP5 = new OscP5(this, 5040); //Audience Port
  loc = new NetAddress("192.168.1.187", 5040); // send to self
  buildUtts(50); //<>//
  mH = new MessageHighlight(20, width/30, height/2, width *5/9, height/2,  messageFont); // adapted from https://processing.org/examples/forceswithvectors.html
  margin1 = new Margin(mH.surf1.width, mH.surf1.height, 0.05);
  pickIncoming(); // pick first utt
  infoSurf = createGraphics(width, height/15); // todo make a progress bar for counted incoming Messages %  total Messages
  frameRate(30);
}

void draw() {
  if (frameCount%50 == 0) {pickIncoming();}
  if (messageIn) {
    background(222);
    messageIn = !messageIn;
  }
  for (int i=0; i<utts.size(); i++) {
    DisplayTD utt = utts.get(i);
    // println("aktuelle utt:    " + utt.utt);
     utt.draw();
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
         PVector gravity = new PVector(0, 0.9 * mH.mass);
         mH.applyForce(gravity);
         mH.update();
      }
  } 
  infoSurf.beginDraw();
  infoSurf.background(222);
  PFont font = createFont(fontlist[25], 25);
  infoSurf.textFont(font);
  infoSurf.fill(20);
  infoSurf.rectMode(CORNER);
  // progress bar for remaining Timer
  infoSurf.text(incomingText + "\t     " + incomingCat , 0, infoSurf.height/2, infoSurf.width, infoSurf.height);
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
      pickIncoming();
      println("   dong   " + nf(ms, 0, 2));
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
    
    // fills the Array utts
    for (int i=0; i<amount; i++) {
      int index = int(random(TD.size()));
      JSONObject row = TD.getJSONObject(str(index));
      String utterance = row.getString("utterance");
      String category = row.getString("category").toLowerCase();
      printArray("category  " + category + "  utt  " + utterance);
      // println("utt:   " + utterance + "   shapeMapping.get(" + category + "):"); 
      // println("\n" + shapeMapping.get(category));
      PShape shape = loadShape(shapeMapping.get(category));
      DisplayTD utt = new DisplayTD(utterance, category, shape, 5, false);
      utts.add(utt);
    }
}
