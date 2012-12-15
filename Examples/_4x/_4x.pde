int r, g, b;

void setup() {
 size(480, 480);
 background(192, 64, 0);
}

void draw() {
 checkValues();
 if (mousePressed) {
    r += 1;  
    g -= 2;
    b += random(4) - 2;
    fill(r, g, b, 64);
 } // else fill(255);
 
 ellipse(mouseX, mouseY, 80, 80); 
}

void checkValues() {
 if (r > 255) r = 0;
 
 if (g < 0) g = 255;
 
 if (b > 255) b = 0;
 if (b < 0) b = 255;
}
