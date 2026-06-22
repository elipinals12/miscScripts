var l1;


function setup() {
    createCanvas(window.innerWidth - 20, window.innerHeight - 20);
}

function draw() {
    background(0);
    l1 = map(mouseX, 0, width, 0, width / 7);
    l2 = map(mouseX, 0, width, 0, width / 6);
    l3 = map(mouseX, 0, width, 0, width / 5);
    l4 = map(mouseX, 0, width, 0, width / 4);
    l5 = map(mouseX, 0, width, 0, width / 3);
    l6 = map(mouseX, 0, width, 0, width / 2);
    l7 = map(mouseX, 0, width, 0, width / 1);
    strokeWeight(0);


    fill(255, 0, 0);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l1 / 2, 0.5 * (height / 7), l1, (height / 7));

    fill(255, 127, 0);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l2 / 2, 1.5 * (height / 7), l2, (height / 7));

    fill(255, 255, 0);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l3 / 2, 2.5 * (height / 7), l3, (height / 7));

    fill(0, 255, 0);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l4 / 2, 3.5 * (height / 7), l4, (height / 7));

    fill(0, 0, 255);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l5 / 2, 4.5 * (height / 7), l5, (height / 7));

    fill(75, 0, 130);
    if (mouseX > (height / 7) - 4 && mouseX < (height / 7) + 4) {
        fill(255);
    }
    ellipse(l6 / 2, 5.5 * (height / 7), l6, (height / 7));

    fill(148, 0, 211);
    if (mouseX > ((width / 7) * 7) - 4 && mouseX < ((width / 7) * 7) + 4) {
        fill(255);
    }
    ellipse(l7 / 2, 6.5 * (height / 7), l7, (height / 7));
}