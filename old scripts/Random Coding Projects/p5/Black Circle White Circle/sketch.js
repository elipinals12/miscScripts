function setup() {
	createCanvas(displayWidth-20, displayHeight-160);
	background(random(0, 256), random(0, 256), random(0, 256));
}

function draw() {	
	if (mouseIsPressed) {
		fill(0);
		stroke(255);
	} else {
		fill(255);
		stroke(0);
	}
	
	ellipse(mouseX, mouseY, 80, 80);
	
	if (keyIsPressed) {
		clear();
		background(random(0, 256), random(0, 256), random(0, 256));
		keyIsPressed = false;
	}
}