boolean holdTimerPassed = false;

class VisibilityMachine {
  static final int STATE_HIDE = 0;
  static final int STATE_GROW = 1;
  static final int STATE_SHRINK = 2;
  static final int STATE_HOLD = 3;
  boolean lock = false;
  int state;
  boolean isVisible = false;
  long holdDurationMs = 1000;

  VisibilityMachine() {
    this.state = VisibilityMachine.STATE_HIDE;
  }

  void start() {
    this.isVisible = true;
    this.state = VisibilityMachine.STATE_GROW;
  }

  void update() {
    if (holdTimerPassed) {
      this.state = VisibilityMachine.STATE_SHRINK;
      holdTimerPassed = false;
    }
    switch (this.state) {
    case VisibilityMachine.STATE_HIDE:
      this.isVisible = false;
    case VisibilityMachine.STATE_GROW:
      if (this.checkGrowCriteria()) {
        this.startHoldState();
      }
    case VisibilityMachine.STATE_HOLD:
      this.isVisible = true;
    case VisibilityMachine.STATE_SHRINK:
      if (this.checkShrinkCriteria()) {
        this.state = VisibilityMachine.STATE_HIDE;
        this.isVisible = false;
      }
    }
  }

  void startHoldState() {
    this.state = VisibilityMachine.STATE_HOLD;
    timer.schedule(new TimerTask() {
      public void run() {
        holdTimerPassed = true;
      }
    }
    , this.holdDurationMs);
  }

  boolean checkGrowCriteria() {
    return true;
  }

  boolean checkShrinkCriteria() {
    return true;
  }
}

void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/display_input") == true) {
    // println("\tINCOMING :" + m.arguments()[0]);
    oscTextIn = parseJSONObject((String) m.arguments()[0]);
    incomingText = oscTextIn.getString("text");
    incomingCat = oscTextIn.getString("cat");
    JSONObject kin = oscTextIn.getJSONObject("kin");
    String kinText = kin.getString("text");
    String kinCat = kin.getString("cat");

    // TODO only set properties if cycle is not running
    incSurf.setTexts(incomingText, incomingCat);
    matchSurf.setTexts(kinText, kinCat);
    //vcprintln("incoming CAt  " + incomingCat);
    currentCol = findColor(incomingCat);
    category_counter = oscTextIn.getJSONObject("category_counter");

    for (String c : cats) {
      JSONObject cat = category_counter.getJSONObject(c);
      int lim = cat.getInt("limit");
      if (lim == -1) {
        currentPart = c;
      }
    }
    JSONObject newIncomingCat = category_counter.getJSONObject(incomingCat);
    cat_limit = newIncomingCat.getInt("limit");
    cat_counts = newIncomingCat.getInt("count");
    println("new utt: " + incomingText);
    sculptureSurf.addElements(incomingText, incomingCat);
    messageIn = true;
    PShape shape = loadShape(shapeMapping.get(incomingCat));
    float shapeSize = cat_counts * 10;
    // add new utterance to utts
    int newIndex = utts.size();
    incomingUtt = new DisplayTD(newIndex, incomingText, incomingCat, "kommentariat", shape, shapeSize, true);
    updateUtts();
    StringList updated = new StringList();
    for (int x=0; x<utts.size(); x++) {
      DisplayTD utt = utts.get(x);
      if (utt.isShape) {
        updated.append(utt.utt);
        //println("updated  " + updated.size() + " items");
      }
    }
    uttCount += 1;
    // println("increment:  " + prgIncrement + "   uttcount:   " + uttCount);
  } else if (m.checkAddrPattern("/display_init") == true) {
    // println("\tINCOMING :" + m.arguments()[0]);
    JSONObject data = parseJSONObject((String) m.arguments()[0]);
    int max_utt = data.getInt("max_utts");
    // JSONObject cats = data.getJSONObject("categories");
    maxUtts = max_utt;
    prgIncrement = width/maxUtts;
  } else if (m.checkAddrPattern("/article")) {
    articleSurf.updateLine((String) m.arguments()[0]);
  }
}

void updateUtts() {
  // replace one utt with noShape with newUtt (hasShape)
  Iterator itr = utts.iterator();
  while (itr.hasNext()) {
    DisplayTD utt = (DisplayTD)itr.next();
    if (utt.isShape != true) itr.remove();
    break; // just remove one utt
  }
  utts.add(incomingUtt);
  // println(" still  updating2?   " + updateUtts + " " + frameCount);
} 




// mock for incoming String messages. 
void pickIncoming() {
  if (!sM.theLock) {
    int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(index));
    String utterance = row.getString("utterance");
    String category = row.getString("category");
    incomingText = utterance;
    incomingCat = category;
    // println("new incoming: " + incomingText);
    background(222);
  }
}
