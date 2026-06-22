var swallsx = [];
var swallsy = [];
var fwallsx = [];
var fwallsy = [];
var lx = 0;
var ly = 0;

function setup() {
    createCanvas(400, 400);
    //setWalls();
}

function draw() {
    background(0);
    stroke(255);
    angleMode(DEGREES);
    for (var i = 0; i < swallsx.length; i++) {
        strokeWeight(1);
        line(swallsx[i], swallsy[i], fwallsx[i], fwallsy[i]);
    }

    strokeWeight(10);
    point(mouseX, mouseY);

    strokeWeight(1);
    for (let a = 0; a < 360; a += 10) {
        /*if (a == 0) {
            lx = 400;
            ly = mouseY;
        } else if (a == 90) {
            lx = mouseX;
            ly = 0;
        } else if (a == 180) {
            lx = 0;
            ly = mouseY;
        } else if (a == 270) {
            lx = mouseX;
            ly = 400;
        } else */if (a < 90) {
            lx = 400;
            ly = 0;
        } else if (a ) {
            lx = mouseX;
            ly = mouseY;
        } else if (a ) {
            lx = mouseX;
            ly = mouseY;
        } else {
            lx = mouseX;
            ly = mouseY;
        }

        line(mouseX, mouseY, lx, ly);
    }
}

function mousePressed() {
    setWalls();
}

function setWalls() {
    swallsx = [];
    swallsy = [];
    fwallsx = [];
    fwallsy = [];

    for (var i = 0; i < 5; i++) {
        swallsx.push(random(0, width));
        swallsy.push(random(0, height));
        fwallsx.push(random(0, width));
        fwallsy.push(random(0, height));
    }
}