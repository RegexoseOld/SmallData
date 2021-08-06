export default function sketch(p){
  let tSize = 10;
  //let p, inP;
  var font;
  let currentPart, nextPart;
  let barWidth, barHeight, yPos
  var counterData = {};
  var parts = {};
  let categories = ["praise", "dissence", "insinuation", "concession", "lecture"]
  let canvas;


  let counter = counterData['category_counter'];
  let locked = counterData['is_locked'];
  barHeight = 30;
  let yOff = p.height / 2;
  let xOff = 50;
  let barOff = 120;
  yPos = 40;

  function findColor(cat) {
    let col = p.color(0);
    if (cat == "praise") {
      col = p.color(196, 128, 79);
    } else if (cat == "dissence") {
      col = p.color(150, 63, 146);
    } else if (cat == "insinuation") {
      col = p.color(21, 143, 84);
    } else if (cat == "lecture") {
      col = p.color(23, 139, 189);
    } else if (cat == "concession") {
      col = p.color(133, 138, 37);
    }
    return col;
  }

  function gotCounter(data) {
    counterData = data;
  }

  function gotParts(data) {
    parts = data;
  }

  function displayCounter() {

      for (let i = 0; i < categories.length; i++) {
        let cat = categories[i];
        var limit = p.int(counter[cat].limit);
        var barCount = p.int(counter[cat].count);
        // console.log("cat " + cat + " barcount " + barCount);


        let col = findColor(cat);
        p.fill(col);
        p.noStroke();
        if (limit < 0) {
          barWidth = 0;
          p.text("currently playing", 200, yOff + (yPos) * i);
        } else if (limit < 0 && locked) {
          barWidth = 0;
          p.textSize(15);
          p.text('neuer Songpart wird geladen. Eingabe hat gerade keinen Effekt', 200, yOff + (yPos * i), p.width / 3, 200);
      } else {
        barWidth = 60
      }
      p.text(cat, xOff, yOff + (yPos) * i);
      p.rectMode(p.CORNER);
      p.rect(xOff + barOff, yOff + (yPos * i), barCount * barWidth, barHeight);
      p.noFill();
      p.stroke(0);
      p.rect(xOff + barOff, yOff + (yPos * i), limit * barWidth, barHeight + 5);
      p.fill(0);
      if (barCount >= limit - 2 && limit > 0) {
        p.textSize(20);
        p.text("nur noch " + (limit + 1 - barCount) + " x " + cat + " bis zum " + cat + "-part", 120 + limit * barWidth + 20, yOff + (yPos * i));
      }
    }
  }


  p.preload = () => {
    font = p.loadFont('../../assets/BebasNeue.otf');
    p.loadJSON('../../assets/parts.json', gotParts);
    p.loadJSON('../../assets/data.json', gotCounter);
  }

  p.updateParts = () => {
    p.loadJSON('../../assets/parts.json', gotParts);
    console.log('updating parts');
  }

  p.setup = () => {
    canvas = p.createCanvas(800, 600);
    //print('lemon boob');
    //setInterval(updateParts, 4000);
    //p.setInterval(p.updateCounter, 2000);
    p.textFont(font, 20);
    p.textAlign(p.LEFT, p.TOP);
    p.rectMode(p.CENTER);
  }

  p.updateCounter = () => {
    console.log('updating counter');
    p.loadJSON('../..//data.json', gotCounter);
  }

  p.draw = () => {
    p.background(220);
    if (counterData) {
       displayCounter();
    }
  }
}

