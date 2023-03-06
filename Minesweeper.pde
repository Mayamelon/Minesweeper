private Hexagon[][] hexes;
private boolean isLost = false;

void setup() {
  size(1280, 720);
  hexes = new Hexagon[14][23];
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      hexes[i][j] = new Hexagon(((i%2==0) ? j : j+0.5)*30*Math.sqrt(3)+60, i*(30*Math.sqrt(3)/2)*Math.sqrt(3)+70, 30, color(255, 244, 121));
    }
  }
  
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      ArrayList <Hexagon> n = new ArrayList <Hexagon> ();
      
      if (j > 0) n.add(hexes[i][j-1]);
      if (j < hexes[i].length-1) n.add(hexes[i][j+1]);
      
      if (i%2 == 0) {
        if (i > 0) {
          n.add(hexes[i-1][j]);
          if (j>0) n.add(hexes[i-1][j-1]);
        }
        if (i < hexes.length-1) {
          n.add(hexes[i+1][j]);
          if (j>0) n.add(hexes[i+1][j-1]);
        }
      }
      else {
        if (i > 0) {
          n.add(hexes[i-1][j]);
          if (j<hexes[i-1].length - 1) n.add(hexes[i-1][j+1]);
        }
        if (i < hexes.length-1) {
          n.add(hexes[i+1][j]);
          if (j< hexes[i-1].length - 1) n.add(hexes[i+1][j+1]);
        }
      }
      
      
      Hexagon[] h = new Hexagon[n.size()];
      
      for (int k = 0; k < n.size(); k++) {
        h[k] = n.get(k);
      }
      
      hexes[i][j].setNeighbors(h);
    }
  }
}

void draw() {
  background(0);
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      hexes[i][j].show();
    }
  }
  if (isLost) {
    revealAll();
    textAlign(CENTER, CENTER);
    textSize(80);
    fill(0);
    text("U+1F92F    D:", 0, 0, width, height);
    return;
  }
  if (isWon()) {
    textAlign(CENTER, CENTER);
    textSize(80);
    fill(0);
    text("U+1F41D    :D", 0, 0, width, height);
    return;
  }
}

boolean isWon() {
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      if (!hexes[i][j].isBomb() && !hexes[i][j].isRevealed()) return false;
    }
  }
  return true;
}

void revealAll() {
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      hexes[i][j].reveal();
    }
  }
}

void mousePressed() {
  for (int i = 0; i < hexes.length; i++) {
    for (int j = 0; j < hexes[i].length; j++) {
      if (hexes[i][j].isPressed(mouseX, mouseY)) {
        if (mouseButton == LEFT) {
          hexes[i][j].reveal();
          if (hexes[i][j].countNeighbors() == 0) {
            hexes[i][j].revealNeighbors();
          }
        }
        if (mouseButton == RIGHT) {
          hexes[i][j].flag();
        }
      }
    }
  }
}

public class Hexagon {

  private double myX, myY, sideLength;

  private color myColor;
  
  private boolean bomb, revealed, flagged;

  private Hexagon [] neighbors;

  public Hexagon(double x, double y, double len, color col) {
    myX = x;
    myY = y;
    sideLength = len;
    myColor = col;
    bomb = (Math.random() < 0.15);
    revealed = false;
    flagged = false;
  }

  public void show() {
    if (!revealed) fill((isOver(mouseX, mouseY)) ? (flagged) ? color(142, 185, 255) : color(201, 169, 61) : (flagged) ? color(157, 228, 255) : myColor);
    else fill(myColor);
    beginShape();
    vertex((float)(myX), (float)(myY + sideLength));
    vertex((float)(myX + Math.sqrt(3) * sideLength/2), (float)(myY + sideLength/2));
    vertex((float)(myX + Math.sqrt(3) * sideLength/2), (float)(myY - sideLength/2));
    vertex((float)(myX), (float)(myY-sideLength));
    vertex((float)(myX - Math.sqrt(3) * sideLength/2), (float)(myY - sideLength/2));
    vertex((float)(myX - Math.sqrt(3) * sideLength/2), (float)(myY + sideLength/2));
    endShape(CLOSE);
    if (revealed && !bomb && countNeighbors() > 0) {
      fill(0);
      textSize(12);
      text(countNeighbors(), (float)myX, (float)myY);
    }
  }
  
  public void setNeighbors(Hexagon[] n) {
    neighbors = n;
  }
  
  public Hexagon[] getNeighbors() {
    return neighbors;
  }
  
  public int countNeighbors() {
    int sum = 0;
    for (int i = 0; i < neighbors.length; i++) {
      if (neighbors[i].isBomb()) sum++;
    }
    return sum;
  }
  
  public void revealNeighbors() {
    for (int i = 0; i < neighbors.length; i++) {
      if (neighbors[i].isRevealed()) continue;
      neighbors[i].reveal();
      if (neighbors[i].countNeighbors() == 0) neighbors[i].revealNeighbors();
    }
  }
  
  public void reveal() {
    if (revealed) {
      int sum = 0;
      for (int i = 0; i < neighbors.length; i++) {
        if (neighbors[i].isFlagged()) sum++;
      }
      if (sum != countNeighbors()) return;
      for (int i = 0; i < neighbors.length; i++) {
        if (!neighbors[i].isFlagged() && !neighbors[i].isRevealed()) {
          neighbors[i].reveal();
        }
      }
      return;
    }
    revealed = true;
    if (bomb) {
      myColor = color(240, 63, 84);
      isLost = true;
    }
    else myColor = color(255, 202, 26);
  }
  
  public void flag() {
    flagged = !flagged;
  }
  
  public boolean isFlagged() {
    return flagged;
  }

  public boolean isOver(double x, double y) {
    return x >= myX - (Math.sqrt(3) * sideLength/2) && x <= myX + (Math.sqrt(3) * sideLength/2) && y >= Math.abs((x-myX)/Math.sqrt(3)) + myY - sideLength && y <= -Math.abs((x-myX)/Math.sqrt(3))+myY+sideLength;
  }

  public boolean isPressed(double x, double y) {
    return mousePressed && isOver(x, y);
  }
  
  public boolean isRevealed() {
    return revealed;
  }
  
  public void setBomb(boolean b) {
    bomb = b;
  }
  
  public boolean isBomb() {
    return bomb;
  }
}
