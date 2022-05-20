void oscEvent(OscMessage m) {
  if (m.checkAddrPattern("/display_input") == true) {
    println("\tINCOMING :" + m.arguments());
    //oscTextIn = parseJSONObject((String) m.arguments()[0]);
    incomingText = (String) m.arguments()[0];
    incomingCat = (String) m.arguments()[1];
    
    println("Incoming: " + incomingText + ", " + incomingCat);
    currentCol = findColor(incomingCat);
    println("new utt: " + incomingText);
    sculptureSurf.addElements(incomingText, incomingCat);
    infoSurf.updateInfo();
    messageIn = true;
    PShape shape = loadShape(shapeMapping.get(incomingCat));
    float shapeSize = cat_counts * 5;
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

void mockIncome(String cat){
  incomingText = "ich weiss genau, dass es ein Brunnengeschäft ist, aber Sie nicht";
  incomingCat = cat;
  sculptureSurf.addElements(incomingText, incomingCat);
  infoSurf.updateInfo();
  messageIn = true;
  
}
