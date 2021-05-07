

void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/display_input") == true) {
    // println("\tINCOMING :" + m.arguments()[0]);
    oscTextIn = parseJSONObject((String) m.arguments()[0]);
    incomingText = oscTextIn.getString("text");
    incomingCat = oscTextIn.getString("cat");
    category_counter = oscTextIn.getJSONObject("category_counter");
    println("counter  " + category_counter);
    JSONObject newIncomingCat = category_counter.getJSONObject(incomingCat);
    cat_limit = newIncomingCat.getInt("limit");
    cat_counts = newIncomingCat.getInt("count");
    surfs[6].visible = true;
    // boolean is_locked = incomingUtt.getBoolean("is_locked");
    messageIn = true;
    println("new utt: " + incomingText);
    PShape shape = loadShape(shapeMapping.get(incomingCat));
    float shapeSize = cat_counts * 10;
    int newIndex= 100;
    incomingUtt = new DisplayTD(newIndex, incomingText, incomingCat, shape, shapeSize, true);
    updateUtts = true;
    updateUtts();
    StringList updated = new StringList();
    for (int x=0; x<utts.size();x++) {
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
    println("\tINCOMING :" + m.arguments()[0]);
    JSONObject data = parseJSONObject((String) m.arguments()[0]);
    int max_utt = data.getInt("max_utts");
    // JSONObject cats = data.getJSONObject("categories");
    maxUtts = max_utt;
    prgIncrement = width/maxUtts;
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
  updateUtts = false;
  // println(" still  updating2?   " + updateUtts + " " + frameCount);
} 

// mock for incoming String messages. 
void pickIncoming() {
  if (!messageLock) {
    int index = int(random(TD.size()));
    JSONObject row = TD.getJSONObject(str(index));
    String utterance = row.getString("utterance");
    incomingText = utterance;
    mH.incoming = incomingText;
    // println("new incoming: " + incomingText);
    background(222);
  }
}
