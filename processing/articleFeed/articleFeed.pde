

PFont font;
String[] fontlist;
StringList article;
String line;
float x, y, tH;
Table table;
boolean nextLine;
int i;



void setup() {
  size(900, 400);
  fontlist =  PFont.list();
  printArray(fontlist);
  font = createFont(fontlist[585], 20, true);
  table = loadTable("Kommentariat.tsv", "header");
  article = makeList("moderation", "intro");

  x = 0;
  y = 0;
  i = 0;
  nextLine = false;
}



void draw() {
  if (nextLine) {
    background(200);
    line = article.get(i % article.size());
    textFont(font, 25);
    textAlign(LEFT, TOP);
    fill(0);
    text(line, 20, height/10, width -20, height *2/3);
  }
  nextLine = !nextLine;
}

void keyReleased() {
  i++;
  nextLine = !nextLine;
}

StringList makeList(String type, String cat) {
  StringList list = new StringList();
  for (TableRow row : table.findRows(type, "type")) {
    if (row.getString("cat").equals(cat)) {
      String line = row.getString("utterance");
      list.append(line);
    }
  }
  return list;
}
