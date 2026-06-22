var thicc = 1;
var size = 1;
var inc = 1;
var g;

function setup() {
    var cnv = createCanvas(800, 800);
    var x = (windowWidth - width) / 2;
    var y = ((windowHeight - height) / 2);
    cnv.position(x, y);
}

function draw() {
    background(0);
    translate(width / 2, height / 2);

    rectMode(CENTER);
    stroke(255);
    noFill();
    strokeWeight(thicc);

    for (var i = 0; i < 5; i++) {
        if (frameCount % 30 < 6) {
            //print("new");
        } else if (frameCount % 30 < 12) {
            //print("new");
        } else if (frameCount % 30 < 18) {
            //print("new");
        } else if (frameCount % 30 < 24) {
            //print("new");
        } else if (frameCount % 30 < 30) {
            //print("new");
        }
    }

    thicc = thicc + .6;
    size = size + inc;
    inc++;
    if (size - thicc > width || size - thicc > height) {
        size = 1;
        inc = 1;
        thicc = 1;
    }
}