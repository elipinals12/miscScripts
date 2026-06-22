

function setup() {
	createCanvas(600, 400);
}

function draw() {
	background(50);
	
	stroke(255);
	strokeWeight(4);
	noFill();
	
	if ((mouseX > 300) && (mouseY < 200)) {
		fill(255, 0, 200);
		ellipse(300, 200, 96, 96);
		noStroke();
	}
	
	if (mouseX > 300) {
		fill(255, 0, 200);
	}
	
	ellipse(300, 200, 100, 100);
	
	if (mouseY > 200) {
		background(50);
	}
}