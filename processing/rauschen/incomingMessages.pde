

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
      //utts.add(utt);
      updateUtts(utt);
      incomingText = text;
      mH.incoming = text;
      messageIn = true;
  }
  /* print the address pattern and the typetag of the received OscMessage */
}

void updateUtts(DisplayTD newUtt) {
  // println("Utts before: " + utts.size());
  Iterator itr = utts.iterator();
  while (itr.hasNext()) {
    DisplayTD utt = (DisplayTD)itr.next();
    if (utt.isShape != true) itr.remove();
    break;
  }
  utts.add(newUtt);
  for (DisplayTD utt : utts) {
    if (utt.isShape) {println("has shape: " + utt.utt); }
    else {println("no shape;   " + utt.utt);}
  }

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
