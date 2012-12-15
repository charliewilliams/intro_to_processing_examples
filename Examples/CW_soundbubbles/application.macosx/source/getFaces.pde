void getFaces() {

  faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );
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
    faceX = int(faces[i].x*2 + faces[i].width/1.0); // remove multiples if not scaling the camera!
    faceY = int(faces[i].y*2 + (faces[i].height)*1.75);

    //    noFill();
    //    stroke(255,0,0);
    //    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
  }
}

void keyPressed () {
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

