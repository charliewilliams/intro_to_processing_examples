void doSuperBubble() {
  newBallID = balls.size();
  colorMode(HSB);
  chroma += int(random(-2, 2));
  if(eventTimer > 50) {
    balls.add(new Ball(faceX, faceY, (eventTimer / (random(10)+1)), newBallID, balls, chroma));
  } else {
    balls.add(new Ball(faceX, faceY, eventTimer, newBallID, balls, chroma));
  }
}

