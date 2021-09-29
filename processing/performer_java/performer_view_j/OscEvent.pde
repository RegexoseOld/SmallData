void oscEvent(OscMessage m) {
  //println("message addr pattern"  + m.addrPattern());
  if (m.checkAddrPattern("/beat")) {
    String currentBeat = (String) m.arguments()[0];
    String change_color = (String) m.arguments()[1];
    String current_part_name = (String) m.arguments()[2];
    String next_part_name = (String) m.arguments()[3];
    beat.updateBeatnum(currentBeat, change_color);
    parts.updateParts(current_part_name, next_part_name);
  }
  if (m.checkAddrPattern("/counter")) {
    JSONObject newData = parseJSONObject((String) m.arguments()[0]);
    JSONObject newCounter = newData.getJSONObject("category_counter");
    boolean is_locked = newData.getBoolean("is_locked");
    songstatus.updateStatus(newCounter, is_locked);
  }
   
}
