var wallwidth = 10;
var pathwidth = 2 * wallwidth;

function setup() {
    // MAKE SURE canvas values - 4*wallwidth are divisible by 3*wallwidth
    var cnv = createCanvas(640, 640);
    var x = (windowWidth - width) / 2;
    var y = ((windowHeight - height) / 2);
    cnv.position(x, y);

    background(85, 5, 255);
    nodes();
    makeMaze();
}

function draw() {
    noStroke();


    // Boarders    
    fill(255);
    rect(0, 0, wallwidth, height);
    rect(pathwidth + wallwidth, 0, width, wallwidth);
    rect(width - wallwidth, 0, width, height);
    rect(0, height - wallwidth, width - wallwidth - pathwidth, height);

}

function nodes() {
    var inheight = height - wallwidth * 2;
    var inwidth = width - wallwidth * 2;

    var wallamty = (inheight - pathwidth) / (wallwidth + pathwidth);
    var wallamtx = (inwidth - pathwidth) / (wallwidth + pathwidth);

    var nodeamty = wallamty + 1;
    var nodeamtx = wallamtx + 1;

    var nodeposy = [];
    var nodeposx = [];

    var wallposy = [];
    var wallposx = [];

    for (let i = 1; i <= wallamty; i++) {
        append(wallposy, i * (pathwidth + wallwidth))
    }
    for (let i = 1; i <= wallamtx; i++) {
        append(wallposx, i * (pathwidth + wallwidth))
    }

    for (let i = 0; i <= nodeamty; i++) {
        append(nodeposy, wallwidth + pathwidth / 2 + i * (pathwidth + wallwidth));
    }
    for (let i = 0; i <= nodeamtx; i++) {
        append(nodeposx, wallwidth + pathwidth / 2 + i * (pathwidth + wallwidth));
    }

    noStroke();
    fill(255);
    for (var i = 0; i < wallposy.length; i++) {
        rect(0, wallposy[i], width, wallwidth);
    }
    for (var i = 0; i < wallposx.length; i++) {
        rect(wallposx[i], 0, wallwidth, height);
    }

    noStroke();
    fill(0);
    for (var g = 0; g < nodeposx.length; g++) {
        for (var i = 0; i < nodeposy.length; i++) {
            //circle(nodeposx[g], nodeposy[i], 5);
        }
    }


}

function makeMaze() {
    var inheight = height - wallwidth * 2;
    var inwidth = width - wallwidth * 2;

    var wallamty = (inheight - pathwidth) / (wallwidth + pathwidth);
    var wallamtx = (inwidth - pathwidth) / (wallwidth + pathwidth);

    var nodeamty = wallamty + 1;
    var nodeamtx = wallamtx + 1;
    var nodeamt = nodeamtx * nodeamty;

    var cellpos = [createVector(wallwidth, wallwidth)];
    var celldirx;
    var celldiry;
    var one = [-1, 1];
    var xory = [true, false];

    var i = 0;
    for (var i = 1; i < 200; i++) {

        celldiry = random(one);
        celldirx = random(one);

        var old = cellpos[i - 1];

        for (var n = 0; n < cellpos.length; n++) {
            
        }

        rectMode(CORNERS);
        fill(255, 5, 5);
        if ((random(xory)) && ((old.x + celldirx * (wallwidth + pathwidth)) > 0) && ((old.x + celldirx * (wallwidth + pathwidth)) < width)) {
            if (cellpos.indexOf(createVector(old.x + celldirx * (wallwidth + pathwidth), old.y)) == -1) {
                append(cellpos, createVector(old.x + celldirx * (wallwidth + pathwidth), old.y));
                rect(old.x, old.y, cellpos[i].x, cellpos[i].y + pathwidth);
            }
        } else if ((old.y + celldiry * (wallwidth + pathwidth) > 0) && (old.y + celldiry * (wallwidth + pathwidth) < height)) {
            if (cellpos.indexOf(createVector(old.x, old.y + celldiry * (wallwidth + pathwidth))) == -1) {
                append(cellpos, createVector(old.x, old.y + celldiry * (wallwidth + pathwidth)));
                rect(old.x, old.y, cellpos[i].x + pathwidth, cellpos[i].y);
            }
        } else {
            i--;
        }
        

        function checkRep(pos) {
            return pos
        }
    }
    print(cellpos.length);
    print(cellpos);
}

function mousePressed() {

}