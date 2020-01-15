/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  println(" addrpattern: "+theOscMessage.addrPattern() +"\n");
  // println(" typetag: "+theOscMessage.typetag() +"\n");
  if(theOscMessage.checkAddrPattern("/parts") == true) {
    String part = theOscMessage.get(0).stringValue();
    if (part.equals("ende")) {
      part_list.append(part);
      song_build(part_list);
      loop();
    } else {
    part_list.append(part);
    }
  } else if (theOscMessage.checkAddrPattern("/part_info") == true) {
    String current_part_info = theOscMessage.get(0).stringValue();
    next_part_name = theOscMessage.get(1).stringValue();
    // println("current part:     " + current_part_name + "   next part:     " + next_part_name);
    task_update(current_part_info, next_part_name);
  
  } else if (theOscMessage.checkAddrPattern("/beat") == true) {
    beat = theOscMessage.get(0).stringValue();
    color c = color(0, 153, 0);
    if (theOscMessage.get(1).stringValue().equals("True")) {
      c = color(255 , 0 , 0);
    }
    beat_update(beat, c); 

    current_part_name = theOscMessage.get(2).stringValue();
    next_part_name = theOscMessage.get(3).stringValue();
    task_update(current_part_name, next_part_name);
   
   } else if (theOscMessage.checkAddrPattern("/advance") == true) {
    String advance_to = theOscMessage.get(0).stringValue();
    if (advance_to.equals(previous_part_name) == false) {
      println("advance to:   " + advance_to); 
      song_update(advance_to); 
    }
  
  } else {
    message = theOscMessage.get(0).stringValue();
    cat = theOscMessage.get(1).stringValue();
    position_utts(message, cat);
  }
  redraw();
}
