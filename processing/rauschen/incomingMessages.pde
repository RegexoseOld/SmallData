

void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/display_input") == true) {
      // println("\tINCOMING :" + m.arguments()[0]);
      incomingUtt = parseJSONObject((String) m.arguments()[0]);
      String text = incomingUtt.getString("text");
      String cat = incomingUtt.getString("cat");
      JSONObject counter = incomingUtt.getJSONObject("category_counter");
      // boolean is_locked = incomingUtt.getBoolean("is_locked");
      println("new utt: " + text);
      PShape shape = loadShape(shapeMapping.get(cat));
      float shapeSize = float(counter.getInt(cat)) * 10;
      DisplayTD utt = new DisplayTD(text, cat, shape, shapeSize, true);
      updateUtts(utt);
      incomingText = text;
      incomingCat = cat;
      mH.incoming = text;
      uttCount += 1;
      println("inc:  " + prgIncrement + "   uttcount:   " + uttCount);
      messageIn = true;
  } else if (m.checkAddrPattern("/display_init") == true) {
      println("\tINCOMING :" + m.arguments()[0]);
      JSONObject data = parseJSONObject((String) m.arguments()[0]);
      int max_utt = data.getInt("max_utts");
      JSONObject cats = data.getJSONObject("categories");
      printArray("max_utts:  " + max_utt);
      maxUtts = max_utt;
      prgIncrement = width/maxUtts;
  }
}

void updateUtts(DisplayTD newUtt) {
  // replace one utt with noShape with newUtt (hasShape)
  Iterator itr = utts.iterator();
  while (itr.hasNext()) {
    DisplayTD utt = (DisplayTD)itr.next();
    if (utt.isShape != true) itr.remove();
    break; // just remove one utt
  }
  utts.add(newUtt);
  //for (DisplayTD utt : utts) {
  //  if (utt.isShape) {println("has shape: " + utt.utt); }
  //  else {println("no shape;   " + utt.utt);}
  //}

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
