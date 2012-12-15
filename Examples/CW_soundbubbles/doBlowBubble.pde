void doBlowBubble() {
  fill(chroma,75);
  ellipse(faceX, faceY, eventTimer*3, eventTimer*3);
  temp.add(new Ball(faceX, faceY, eventTimer*3, eventTimer*3, temp));
  if(temp.size() > 1) {
    temp.remove(temp.size() - 1);
  }
}

