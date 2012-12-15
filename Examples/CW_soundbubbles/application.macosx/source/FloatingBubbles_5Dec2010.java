import processing.core.*; 
import processing.xml.*; 

import java.awt.Rectangle; 
import processing.opengl.*; 
import hypermedia.video.*; 
import java.util.ArrayList; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class FloatingBubbles_5Dec2010 extends PApplet {

/*
 Bubble motion based on code from Keith Peters' bit-101.com
 Popping sound by 'Hell's Sound Guy' on Freesound.org
 Downloadable app icon by everaldo.com
 Optical flow inspired by Andy Best at Andybest.net
 */


Rectangle[] faces;

int faceX, faceY;
OpenCV opencv;
PImage mvtImg;
PImage img1, img2;

ArrayList balls;
ArrayList temp;


Minim minim;
AudioSnippet popSnd;
AudioInput in;
float audioAmp;
float sampleAmp;
int loudness;
FFT fft;
final int NROWS = 18;
final int NCOLS = 24;
final float LIMIT = 40.0f;
int w,h;
PFont font;

Point[][] vecArray = new Point[640][480];

int numBalls = 20;
int counter = 0;

float spring = 0.005f;
float friction = -0.9f;
float wobble = 0.5f;

float thePitch = 0.0f;
float rawPitch = 0.0f;
int _pitch = 0;
int _prevPitch = 0;
int eventTimer = 0;
int prevTimer = 0;
boolean blowBubble = false;
boolean info = false;
boolean superBubble = false;
int newBallID = 0;
int chroma = color(255,255,75);

public void setup() {
  //  size(640,480,P2D);
  size(640,480,JAVA2D);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  w = width/(NCOLS*2);
  h = height/(NROWS*2);
  img1 = createImage(width,height,ARGB);
  img2 = createImage(width,height,ARGB);
  frame.setBackground(new java.awt.Color(0, 0, 0));
  frame.setTitle("sound bubbles | 2010 | charlie williams");
  noStroke();
  smooth();
  opencv = new OpenCV(this);
  opencv.capture(width/2,height/2);
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 4096);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.window(FFT.HAMMING);
  balls = new ArrayList();
  temp = new ArrayList();
  for (int i=0;i<numBalls;i++) {
    balls.add(new Ball(random(width), random(height), random(20,40), i, balls,
    color(random(255),random(255),random(255),random(255))));
  }
}

public void draw() {
  img2.copy(img1,0,0,img1.width,img1.height,0,0,img2.width,img2.height);
  img2.updatePixels();
  opencv.read();
  opencv.flip(OpenCV.FLIP_HORIZONTAL);
  img1 = opencv.image();
  img1.updatePixels();
  image(img1, 0, 0, width, height); // allows scaling up!
  doFindPitch();
  if(eventTimer > 100) {
    superBubble = true;
  }
  if(blowBubble && superBubble) {
    doSuperBubble();
  }
  else if (blowBubble) {
    doBlowBubble();
  }
  findFlow();
  for (int i=0; i<balls.size(); i++) {
    Ball b = (Ball) balls.get(i);
    b.ripple();
    if(counter%20==0) {
      b.swish();
    }
    b.pop();
    b.collide();
    b.move();
    b.display();
  }
  if(balls.size() < 4) {
    balls.add(new Ball(random(width), random(height), random(20,40), balls.size(), balls, color(random(255),random(255),random(255))));
  }
  counter++;
  if(counter > 2147483645) {
    counter = 0;
  }
  if(info || counter < 100) {
    fill(255);
    text(frameRate, width - 60, 20);
    text(balls.size(), 10, 20);
    text("type \'i\' to hide or show info", 40, 20);
    text("type \'s\' to blow a burst of superbubbles", 40, 40);
    text("type \'m\' for more random bubbles", 40, 60);
  }
}

public void stop()
{
  opencv.stop();
  popSnd.close();
  in.close();
  minim.stop();
  super.stop();
}

class Ball {
  float x, y;
  float diameter;
  float wdiameter;
  float hdiameter;
  float vx = random(-0.2f, 0.2f);
  float vy = random(-0.2f, 0.2f);
  int id;
  int c;
  ArrayList others;
  float gravity = 0.0001f;

  Ball(float _x, float _y, float _d, int _id, ArrayList _others) {
    x = _x;
    y = _y;
    diameter = _d;
    wdiameter = _d;
    hdiameter = _d;
    id = _id;
    others = _others;
  }

  Ball(float _x, float _y, float _d, int _id, ArrayList _others, int chroma) {
    this(_x, _y, _d, _id, _others);
    this.c = chroma;
  }

  public void collide() {
    for (int i = id + 1; i < balls.size(); i++) {
      Ball other = (Ball) balls.get(i);
      float dx = other.x - x;
      float dy = other.y - y;
      float distance = sqrt (dx*dx + dy*dy);
      float minDist = other.diameter/2 + diameter/2;
      if(distance < minDist) {
        float angle = atan2(dy,dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - other.x) * spring;
        float ay = (targetY - other.y) * spring;
        vx -= ax;
        vy -= ay;
        other.vx += ax;
        other.vy += ay;
      }
    }
  }

  public void swish() {
    int nearCol = PApplet.parseInt(this.x / (w-1));
    int nearRow = PApplet.parseInt(this.y / (h-1));

    //nearRow = -(nearRow - h);
    //    println(nearCol+ " " + nearRow);
    if (nearCol > 22) {
      nearCol = 22;
    } 
    if (nearRow > 16) {
      nearRow = 16;
    }

    Point newVelPoint = new Point(0,0);

    int changeX, changeY;
    for (int j = -1; j < 2; j++) {
      for (int q = -1; q < 2; q++) {
        if(nearRow + j < 0) {
          changeY = 0;
        }
        else {
          changeY = nearRow + j;
          if(changeY > 16) {
            changeY = 16;
          }
        }
        if(nearCol + q < 0) {
          changeX = 0;
        }
        else {
          changeX = nearCol + q;
          if(changeX > 22) {
            changeX = 22;
          }
        }
        Point tempPoint = vecArray[changeY][changeX];
        this.vx += PApplet.parseFloat(tempPoint.x)/60;
        this.vy += PApplet.parseFloat(tempPoint.y)/60;
      }
    }
  }


  public void move() {
    if (this.gravity < -0.0006f) {
      this.gravity += random(0.0f, 0.0001f);
    }
    else if (this.gravity > 0.0008f) {
      this.gravity += random(-0.0001f, 0.0f);
    }
    else {
      this.gravity += random(-0.0003f, 0.0003f);
    }
    vy += this.gravity;
    x += vx;
    y += vy;
  }

  public void ripple() {
    if(wdiameter/hdiameter > 1.1f) {
      // make it narrower
      wdiameter += random(-wobble, 0);
      hdiameter += random(0, wobble);
    }
    else if (wdiameter/hdiameter < 0.9f) {
      // make it wider
      wdiameter += random(0, wobble);
      hdiameter += random(-wobble, 0);
    }
    if (wdiameter/hdiameter <= 1.1f) {
      if (wdiameter/hdiameter >= 0.9f) {
        wdiameter += random(-wobble, wobble);
        hdiameter += random(-wobble, wobble);
      }
    }
    //    diameter = (wdiameter + hdiameter) /2;
  }

  public void pop() {
    if (wdiameter <= 5 || hdiameter <= 5 || y < -100 || y + diameter/2 >= height + 5 || x + diameter/2 < 0 || x - diameter/2 > width) {
      //      println("POP!" + " went #" + id + "... bubbles left: " + balls.size());
      //  removed "too big" popping: wdiameter * hdiameter > width*height/5 || 
      if(balls.size() > 0) {
        balls.remove(this);
      }
      if (balls.size() < 100) { // loading >100 pop sounds at once was killing minim. And, to be fair, it just sounds crazy anyway.
      String A = new String("B_");
      String B = new String(".wav");
      String sndNbr = str(PApplet.parseInt(random(0,10)));
      String sndName = A+sndNbr+B;
      popSnd = minim.loadSnippet(sndName);
      popSnd.play();
      }
    }
  }


  public void display() {
    fill(this.c,75);
    noStroke();
    ellipse(x, y, wdiameter, hdiameter);
    //    pushMatrix();
    //    translate(x, y);
    //    float r = random(0, 1);
    //    if(r < 0.5) {
    //      sphere(wdiameter/2);
    //    }
    //    else {
    //      sphere(hdiameter/2);
    //    }
    //    popMatrix();
    stroke(255);
    point(x,y);
    noStroke();
  }
}

public void doBlowBubble() {
  fill(chroma,75);
  ellipse(faceX, faceY, eventTimer*3, eventTimer*3);
  temp.add(new Ball(faceX, faceY, eventTimer*3, eventTimer*3, temp));
  if(temp.size() > 1) {
    temp.remove(temp.size() - 1);
  }
}

public void doFindPitch() {

  // PITCH FOR NOTE-ON DETECTION
  fft.forward(in.mix);
  _prevPitch = _pitch;
  _pitch *= 0.6f; // falloff factor

  for (int i = 0; i < fft.specSize(); i++) {
//    stroke(255);
//    line(i*5, height, i*5, height - fft.getBand(i) * 4); // draw whole spectrum

    // Make 'i' the number of the loudest band:
    if (fft.getBand(i) > _pitch) {
      _pitch = i;
//      stroke(255,0,0);
//      line(i*5, height, i*5, height - fft.getBand(_pitch) * 4); // draw just the red peak(s)
    }
  }

  noStroke();
  prevTimer = eventTimer;
  println(_prevPitch + " " + _pitch + " " + eventTimer);

  // CHECK WITH SINGING
  if (_pitch >= 10) {
    blowBubble = true;
    eventTimer++;
    getFaces();
  }
  //  if (blowBubble && abs(_prevPitch - _pitch) < 400 && _pitch >= 4) {
  if (blowBubble && _pitch >= 4 && eventTimer > 5) {
    rawPitch += _pitch;
    thePitch = rawPitch / prevTimer;
    colorMode(HSB);
    chroma = color(PApplet.parseInt(map(thePitch, 0, 512, 0, 255)), PApplet.parseInt(map(thePitch, 0, 512, 255, 0)), PApplet.parseInt(map(thePitch, 0, 512, 200, 255)));
  }
  else if (_pitch < 2) {
    blowBubble = false;
    eventTimer = 0;
    superBubble = false;
    if (temp.size() > 0) {
      // This indicates the event has stopped:
      if (prevTimer - eventTimer > 5) {
        balls.add(new Ball(faceX, faceY, prevTimer*3, balls.size(), balls, chroma));
        temp.remove(temp.size()-1);
      }
    }
  }
}

public void doSuperBubble() {
  newBallID = balls.size();
  colorMode(HSB);
  chroma += PApplet.parseInt(random(-2, 2));
  if(eventTimer > 50) {
    balls.add(new Ball(faceX, faceY, (eventTimer / (random(10)+1)), newBallID, balls, chroma));
  } else {
    balls.add(new Ball(faceX, faceY, eventTimer, newBallID, balls, chroma));
  }
}


class Point {
  // It is a temporary data structure to hold a point information.
  int x, y;

  Point(int _x, int _y) {
    x = _x;
    y = _y;
  }
}

public void findFlow() {
  int xOff = w/2;
  int yOff = h/2;
  for (int r=1;r<NROWS;r++) {
    for (int c=1;c<NCOLS;c++) {
      Point p1 = new Point(c*w, r*h);
      Point p2 = findPoint(p1.x, p1.y, xOff, yOff);

      vecArray[r-1] [c-1] = new Point( (p2.x - p1.x)/2, (p2.y - p1.y)/2 );
      stroke(255);
//      drawLine(p1,p2);
    }
  }
}

public void drawLine(Point _p, Point _q) {
  // draw the arrow line from point _q to point _p.
  if (_p.x!=_q.x || _p.y!=_q.y) {
    line(_p.x,_p.y,_q.x,_q.y);
    float ang = atan2(_q.y-_p.y,_q.x-_p.x);
    float ln = width/3.0f;
    float tx = _p.x + ln*cos(ang-PI/6);
    float ty = _p.y + ln*sin(ang-PI/6);
    line(_p.x,_p.y,tx,ty);
    tx = _p.x + ln*cos(ang+PI/6);
    ty = _p.y + ln*sin(ang+PI/6);
    line(_p.x,_p.y,tx,ty);
  } 
  else {
    line(_p.x,_p.y,_q.x,_q.y);
  }
}

public Point findPoint(int _x, int _y, int _xo, int _yo) {

  // Given a pixel (_x, _y) in img1, we search the neighborhood of that
  // pixel in img2 and try to find a matching colour.
  // 
  // The neighborhood size is defined by (w x h) and the boundaries are
  // x0 - left
  // x1 - right
  // y0 - top
  // y1 - right

  int x0 = _x - _xo;
  int x1 = _x + _xo;
  int y0 = _y - _yo;
  int y1 = _y + _yo;

  // Initialize the minimum difference to a high value.
  // Loop through the pixels in img2 within the boundary.
  // Find the pixel with minimum difference from the original one 
  // in img1.
  //  PImage  img1 = opencv.image();
  //  PImage  img2 = createImage(640,480, ARGB);
  //  img2 = opencv.image(OpenCV.MEMORY);

  float minDiff = 999999999;
  Point p = new Point(_x,_y);
  int c1 = img1.pixels[_y*img1.width+_x];
  int c2 = img2.pixels[_y*img2.width+_x];
  if (!matchCol(c1,c2)) {
    for (int r=y0;r<y1;r++) {
      for (int c=x0;c<x1;c++) {
        c2 = img2.pixels[r*img2.width+c];
        float diff = dist(red(c1),green(c1),blue(c1),red(c2),green(c2),blue(c2));
        if (diff<minDiff) {
          minDiff = diff;
          p.x = c;
          p.y = r;
        }
      }
    }
  }
  return p;
}

public boolean matchCol(int c1, int c2) {
  // Compare two colour values and see if they are similar.
  float d = dist(red(c1),green(c1),blue(c1),red(c2),green(c2),blue(c2));
  return (d<LIMIT);
}

public void getFaces() {

  faces = opencv.detect( 1.2f, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
  opencv.absDiff();
  opencv.convert(OpenCV.GRAY);
  opencv.blur(OpenCV.BLUR, 3);
  opencv.threshold(20);
  mvtImg = opencv.image();
  opencv.remember(OpenCV.SOURCE, OpenCV.FLIP_HORIZONTAL);
  for(int i=0; i<faces.length;i++) {
    //    int _faceX = faces[i].x + (faces[i].width)/2;
    //    int _faceY = int(faces[i].y + (faces[i].height)*0.86);
    //    faceX = (faceX + _faceX) / 2;
    //    faceY = (faceY + _faceY) / 2;
    faceX = PApplet.parseInt(faces[i].x*2 + faces[i].width/1.0f); // remove multiples if not scaling the camera!
    faceY = PApplet.parseInt(faces[i].y*2 + (faces[i].height)*1.75f);

    //    noFill();
    //    stroke(255,0,0);
    //    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
  }
}

public void keyPressed () {
  switch(key) {
  case ' ': 
    {
      balls.add(new Ball(random(width), random(height), random(20,40), balls.size()+1, balls));
    }
    break;
  case 'i': 
    {
      if(info) {
        info = false;
      }
      else {
        info = true;
      }
    }
    break;
  case 's':
    {
      if(superBubble) {
        superBubble = false;
      }
      else {
        superBubble = true;
      }
      break;
    }
  case 'm': 
    {
      for (int i=0;i<10;i++) {
        balls.add(new Ball(random(width), random(height), random(20,40), i, balls, color(random(255),random(255),random(255))));
      }
      break;
    }

  case 'p':
    {
      balls.remove(balls.size()-1);
      break;
    }
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "FloatingBubbles_5Dec2010" });
  }
}
