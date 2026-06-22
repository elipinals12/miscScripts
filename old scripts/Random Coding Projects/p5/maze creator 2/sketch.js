var ver, hor;
var tcols, trows;
var wid = 40;
var grid = [];
var current;
var stack = [];
var x, y;

function setup() {
    var cnv = createCanvas(800, 800);
    var x = (windowWidth - width) / 2;
    var y = ((windowHeight - height) / 2);
    cnv.position(x, y);

    tcols = floor(width / wid);
    trows = floor(height / wid);

    for (j = 0; j < trows; j++) {
        for (i = 0; i < tcols; i++) {
            var cell = new Cell(i, j);
            append(grid, cell);
        }
    }

    //frameRate(10);

    current = grid[0];
}

function draw() {
    strokeCap(SQUARE);
    background(85, 5, 255);
    strokeWeight(1);

    wikiSteps();

    // make outer walls
    stroke(0);
    strokeWeight(15);
    line(wid, 0, width, 0);
    line(width, 0, width, height);
    line(width - wid, height, 0, height);
    line(0, 0, 0, height);

    if (grid[0].dead == true) {
        moveGuy();
    }
}

function moveGuy() {
    // TODO:
    // reading the pixels, set the maze as background and 
}