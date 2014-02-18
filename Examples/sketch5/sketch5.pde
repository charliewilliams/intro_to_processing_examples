int r, g, b;
int w, h; // new! variables for ellipse size

void setup() {
  size(480, 480);
  rectMode(CENTER);
  background(192, 64, 0);
  stroke(0, 64);
  fill(255, 127);
  w = h = 20;
}

void draw() {
  checkValues();
  if (mousePressed) {
    r = r + 1;  
    g = g - 2;
    b = b + random(4) - 2;
    fill(r, g, b, 127);
  }

  w = w + random(6) - 3; // try 2?
  h = h + random(6) - 3;

  if (frameCount % 10 == 0) {
    rect(mouseX, mouseY, 40, 40);
  } 
  else {
    ellipse(mouseX, mouseY, w, h);
  }
}

void checkValues() {
  if (r > 255) r = 0;

  if (g < 0) g = 255;

  if (b > 255) b = 0;
  if (b < 0) b = 255;
}
