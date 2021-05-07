

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
  article = new StringList();
  table = loadTable("Kommentariat.tsv", "header");
  for (TableRow row : table.findRows("article", "type")) {
    String line = row.getString("utterance");
    article.append(line);
  }
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
