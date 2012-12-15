void doFindPitch() {

  // PITCH FOR NOTE-ON DETECTION
  fft.forward(in.mix);
  _prevPitch = _pitch;
  _pitch *= 0.6; // falloff factor

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
    chroma = color(int(map(thePitch, 0, 512, 0, 255)), int(map(thePitch, 0, 512, 255, 0)), int(map(thePitch, 0, 512, 200, 255)));
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

