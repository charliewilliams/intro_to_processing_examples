/*
 Bubble motion based on code from Keith Peters' bit-101.com
 Popping sound by 'Hell's Sound Guy' on Freesound.org
 Downloadable app icon by everaldo.com
 Optical flow inspired by Andy Best at Andybest.net
 */
import java.awt.Rectangle;
import processing.opengl.*;
Rectangle[] faces;
import hypermedia.video.*;
int faceX, faceY;
OpenCV opencv;
PImage mvtImg;
PImage img1, img2;
import java.util.ArrayList;
ArrayList balls;
ArrayList temp;
import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioSnippet popSnd;
AudioInput in;
float audioAmp;
float sampleAmp;
int loudness;
FFT fft;
final int NROWS = 18;
final int NCOLS = 24;
final float LIMIT = 40.0;
int w,h;
PFont font;

Point[][] vecArray = new Point[640][480];

int numBalls = 20;
int counter = 0;

float spring = 0.005;
float friction = -0.9;
float wobble = 0.5;

float thePitch = 0.0;
float rawPitch = 0.0;
int _pitch = 0;
int _prevPitch = 0;
int eventTimer = 0;
int prevTimer = 0;
boolean blowBubble = false;
boolean info = false;
boolean superBubble = false;
int newBallID = 0;
color chroma = color(255,255,75);

void setup() {
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

void draw() {
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

void stop()
{
  opencv.stop();
  popSnd.close();
  in.close();
  minim.stop();
  super.stop();
}

