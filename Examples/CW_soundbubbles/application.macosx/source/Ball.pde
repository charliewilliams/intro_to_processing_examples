class Ball {
  float x, y;
  float diameter;
  float wdiameter;
  float hdiameter;
  float vx = random(-0.2, 0.2);
  float vy = random(-0.2, 0.2);
  int id;
  color c;
  ArrayList others;
  float gravity = 0.0001;

  Ball(float _x, float _y, float _d, int _id, ArrayList _others) {
    x = _x;
    y = _y;
    diameter = _d;
    wdiameter = _d;
    hdiameter = _d;
    id = _id;
    others = _others;
  }

  Ball(float _x, float _y, float _d, int _id, ArrayList _others, color chroma) {
    this(_x, _y, _d, _id, _others);
    this.c = chroma;
  }

  void collide() {
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

  void swish() {
    int nearCol = int(this.x / (w-1));
    int nearRow = int(this.y / (h-1));

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
        this.vx += float(tempPoint.x)/60;
        this.vy += float(tempPoint.y)/60;
      }
    }
  }


  void move() {
    if (this.gravity < -0.0006) {
      this.gravity += random(0.0, 0.0001);
    }
    else if (this.gravity > 0.0008) {
      this.gravity += random(-0.0001, 0.0);
    }
    else {
      this.gravity += random(-0.0003, 0.0003);
    }
    vy += this.gravity;
    x += vx;
    y += vy;
  }

  void ripple() {
    if(wdiameter/hdiameter > 1.1) {
      // make it narrower
      wdiameter += random(-wobble, 0);
      hdiameter += random(0, wobble);
    }
    else if (wdiameter/hdiameter < 0.9) {
      // make it wider
      wdiameter += random(0, wobble);
      hdiameter += random(-wobble, 0);
    }
    if (wdiameter/hdiameter <= 1.1) {
      if (wdiameter/hdiameter >= 0.9) {
        wdiameter += random(-wobble, wobble);
        hdiameter += random(-wobble, wobble);
      }
    }
    //    diameter = (wdiameter + hdiameter) /2;
  }

  void pop() {
    if (wdiameter <= 5 || hdiameter <= 5 || y < -100 || y + diameter/2 >= height + 5 || x + diameter/2 < 0 || x - diameter/2 > width) {
      //      println("POP!" + " went #" + id + "... bubbles left: " + balls.size());
      //  removed "too big" popping: wdiameter * hdiameter > width*height/5 || 
      if(balls.size() > 0) {
        balls.remove(this);
      }
      if (balls.size() < 100) { // loading >100 pop sounds at once was killing minim. And, to be fair, it just sounds crazy anyway.
      String A = new String("B_");
      String B = new String(".wav");
      String sndNbr = str(int(random(0,10)));
      String sndName = A+sndNbr+B;
      popSnd = minim.loadSnippet(sndName);
      popSnd.play();
      }
    }
  }


  void display() {
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

