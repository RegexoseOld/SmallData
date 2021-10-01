

void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/display_input") == true) {
    // println("\tINCOMING :" + m.arguments()[0]);
    oscTextIn = parseJSONObject((String) m.arguments()[0]);
    incomingText = oscTextIn.getString("text");
    incomingCat = oscTextIn.getString("cat");
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
    sculptureSurf.displaySculpture(incomingText);
    messageIn = true;
    println("new utt: " + incomingText);
    PShape shape = loadShape(shapeMapping.get(incomingCat));
    float shapeSize = cat_counts * 10;
    // add new utterance to utts
    int newIndex = utts.size();
    incomingUtt = new DisplayTD(newIndex, incomingText, incomingCat, "kommentariat", shape, shapeSize, true);
    updateUtts();
    StringList updated = new StringList();
    for (int x=0;  x<utts.size(); x++) {
      DisplayTD utt = utts.get(x);
      if (utt.isShape) {
        updated.append(utt.utt);
        //println("updated  " + updated.size() + " items");
      }
    }
    mH.newMessage(incomingText);
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
    newArticleLine = parseJSONObject((String) m.arguments()[0]);
    currentArticleLine = newArticleLine.getString("newLine");
    articleSurf.updateLine(currentArticleLine);
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
  if (!messageLock) {
    int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(index));
    String utterance = row.getString("utterance");
    String category = row.getString("category");
    incomingText = utterance;
    incomingCat = category;
    mH.incoming = incomingText;
    // println("new incoming: " + incomingText);
    background(222);
  }
}
