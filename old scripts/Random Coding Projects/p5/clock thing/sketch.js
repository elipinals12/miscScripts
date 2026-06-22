var sc = 0;
var mini = 0;
var hr = 0;
var da = 0;
var mont = 0;
var yer = 0;

var gap = 10;
var cthic = 20;
var lthic = 5;

var csizes = [];
var times = [];
var cangles = [];

function setup() {
    createCanvas(500, 500);
    angleMode(DEGREES);
    for (var i = 0; i < 6; i++) {
        csizes.push(210 + ((2 * cthic + gap) * (i + 1)));
    }
}

function draw() {
    background(0);
    cangles = [];
    times = [];
    translate(width/2, height/2);
    rotate(-90);
    
    strokeWeight(1);
    noFill();
    //ellipse(0, 0, width);

    times.push(second());
    times.push(minute());
    times.push(hour() % 12);
    times.push(day());
    times.push(month());

    
    cangles.push(map(times[0], 0, 60, 0, 360)); // seconds
    cangles.push(map(times[1], 0, 60, 0, 360)); // minutes
    cangles.push(map(times[2], 0, 12, 0, 360)); // hours
    cangles.push(map(times[3], 0, 31, 0, 360)); // days
    cangles.push(map(times[4], 0, 12, 0, 360)); // months

    for (var i = 0; i < times.length; i++) {
        stroke(50 * i, 4 * i, 250);
        strokeWeight(cthic);
        strokeCap(SQUARE);
        arc(0, 0, csizes[i], csizes[i], 0, cangles[i]);

        push();
        rotate(cangles[i]);
        strokeCap(ROUND);
        strokeWeight(lthic);
        line(0, 0, map(i, 0, times.length, 110, 25), 0);
        pop();
    }


    strokeWeight(lthic);
    stroke(255);
    point(0, 0);
}

function mousePressed() {
    print(times);
    print(cangles);
    //print(csizes);
}