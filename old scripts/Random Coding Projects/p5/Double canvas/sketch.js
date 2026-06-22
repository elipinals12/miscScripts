let x = 200;
let y = 200;
let extraCanvas;

function setup() {
	createCanvas(400, 400);
	extraCanvas = createGraphics(400, 400);
	extraCanvas.clear();
	background(0);
}

function draw() {
	
	// No trails
	background(0);
	x += random(-5, 5);
	y += random(-5, 5);
	fill(255, 0, 0);
	stroke(255);
	rectMode(CENTER);
	rect(x, y, 20, 20);
	
	// Trails
	if (mouseIsPressed) {
		extraCanvas.fill(255, 150);
		extraCanvas.noStroke();
		extraCanvas.ellipse(mouseX, mouseY, 60, 60);
	}
	
	image(extraCanvas, 0, 0);
}