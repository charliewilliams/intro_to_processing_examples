
class Point {
  // It is a temporary data structure to hold a point information.
  int x, y;

  Point(int _x, int _y) {
    x = _x;
    y = _y;
  }
}

void findFlow() {
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

void drawLine(Point _p, Point _q) {
  // draw the arrow line from point _q to point _p.
  if (_p.x!=_q.x || _p.y!=_q.y) {
    line(_p.x,_p.y,_q.x,_q.y);
    float ang = atan2(_q.y-_p.y,_q.x-_p.x);
    float ln = width/3.0;
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

Point findPoint(int _x, int _y, int _xo, int _yo) {

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
  color c1 = img1.pixels[_y*img1.width+_x];
  color c2 = img2.pixels[_y*img2.width+_x];
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

boolean matchCol(color c1, color c2) {
  // Compare two colour values and see if they are similar.
  float d = dist(red(c1),green(c1),blue(c1),red(c2),green(c2),blue(c2));
  return (d<LIMIT);
}

