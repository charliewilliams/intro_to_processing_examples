int r, g, b;
// add vars for ellipse size
int w, h;
String my_string;

void setup() {
 size(480, 480);
 background(192, 64, 0);
 stroke(r, g, b, 64);
 smooth();
 w = h = 10;
}

void draw() {
 checkValues();
 if (mousePressed) {
    r += 1;  
    g -= 2;
    b += random(4) - 2;
    fill(r, g, b, 64);
 } // else fill(255);
 w += random(6) - 3; // try 2?
 h += random(6) - 3;
// if (int(random(2)) == 0) {
  if (!(frameCount % 10 == 0)) {
   ellipse(mouseX, mouseY, w, h);
 } else {
   rect(mouseX, mouseY, 20, 20);
//   ellipse(mouseX, mouseY, getArea(), getArea());
 }
 rectMode(CENTER);
 
}
void checkValues() {
 if (r > 255) r = 0;
 
 if (g < 0) g = 255;
 
 if (b > 255) b = 0;
 if (b < 0) b = 255;
}

int getArea() {
  return w*h;
}
