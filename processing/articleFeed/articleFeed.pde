

PFont font;
String[] fontlist;
StringList article;
String line;
float x, y, tH;
Table table;
int i;



void setup() {
  size(900, 400);
  fontlist =  PFont.list();
  font = createFont(fontlist[50], 20);
  article = new StringList();
  table = loadTable("Kommentariat.tsv", "header");
  for (TableRow row : table.findRows("article", "type")) {
    String line = row.getString("utterance");
    article.append(line);
  }
  x = 0;
  y = 0;
  i = 0;
}



void draw() {
  

  if (keyPressed) {
    background(200);
    line = article.get(i % article.size());
    textFont(font, 25);
    textAlign(LEFT, TOP);
    fill(0, 120);
    text(line, 20, height/4, width -20, height/3);
    i++;
  }
}
