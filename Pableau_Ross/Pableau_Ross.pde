import processing.video.*;

Capture cam;
DessinApplet dessin;

// Settings
boolean debugMode = true;

// A variable for the color we are searching for.
color trackColor;

int rectSize = 20;

void setup() {
  size(640, 480);
  colorMode(HSB, 360, 100, 100);

  String[] cameras = Capture.list();

  if (cameras.length == 0) {

    println("There are no cameras available for capture.");
    exit();
  } else {

    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[9]);
    cam.start();

    // Start off tracking for red
    trackColor = color(0, 194, 113);
  }

  // Run draw window
  this.dessin = new DessinApplet();
}

void settings() {
  size(640, 480);
}

void draw() {
  
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);

  // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
  float worldRecord = 200; 

  // XY coordinate of closest color
  int closestRightX = 0;
  int closestRightY = 0;
  int leftPartEnd = cam.width/2;
  int closestLeftX = 0;
  int closestLeftY = 0;

  if (debugMode) {
    line(leftPartEnd, 0, leftPartEnd, cam.height);
  }

  // Begin loop to walk through every pixel
  for (int x = 0; x < leftPartEnd; x ++ ) {
    for (int y = 0; y < cam.height; y ++ ) {
      int loc = x + y*cam.width;
      // What is current color
      color currentColor = cam.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d < worldRecord) {
        worldRecord = d;
        closestRightX = x;
        closestRightY = y;
      }
    }
  }

  for (int x = leftPartEnd; x < cam.width; x ++ ) {
    for (int y = 0; y < cam.height; y ++ ) {
      int loc = x + y*cam.width;
      // What is current color
      color currentColor = cam.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d < worldRecord) {
        worldRecord = d;
        closestLeftX = x;
        closestLeftY = y;
      }
    }
  }

  drawColorPalette(rectSize);

  color newColor = color(get(closestRightX, closestRightY));
  
  fill(newColor);
  rect(0, 0, 10, 10);
  
  println("newColor: " + newColor);

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (worldRecord < 200) {
    // Draw a circle at the tracked pixel
    fill(trackColor);
    strokeWeight(4.0);
    stroke(0);

    if (debugMode) {
      ellipse(closestRightX, closestRightY, 16, 16);
      ellipse(closestLeftX, closestLeftY, 16, 16);
      /*
      System.out.println("Position Droite");
      System.out.println("closestLeftX: " + closestLeftX + "; closestLeftY: " + closestLeftY);
      System.out.println("leftPartEnd: " + leftPartEnd);
      System.out.println("cam.height: " + cam.height);*/
    }

    int inputDirection = 0;
    
    int leftArea = leftPartEnd + leftPartEnd / 3;
    int middleArea = leftPartEnd + (leftPartEnd/3) * 2;

    if (closestLeftY < cam.height/3) {
      if (closestLeftX < leftArea ) {
        inputDirection = 7;
      } else if (closestLeftX < middleArea) {
        inputDirection = 8;
      } else {
        inputDirection = 9;
      }
    } else if (closestLeftY < (cam.height/3)*2) {
      if (closestLeftX < leftArea) {
        inputDirection = 4;
      } else if (closestLeftX < middleArea) {
        inputDirection = 5;
      } else {
        inputDirection = 6;
      }
    } else {
      if (closestLeftX < leftArea) {
        inputDirection = 1;
      } else if (closestLeftX < middleArea) {
        inputDirection = 2;
      } else {
        inputDirection = 3;
      }
    }

    dessin.control(inputDirection, newColor);

    System.out.println("Input Direction: " + inputDirection);
  }
}

void drawColorPalette(int rectSize) {
  colorMode(HSB, width/rectSize, height/rectSize, 255);
  smooth();
  int offset = height/4;
  for(int i = 0; i < width/rectSize ; i++){
   for(int j = 0; j < height/rectSize ; j++){
     noStroke();
     fill(i,j,255);
     //dibuja cuadrados del tamano definido
     //agrega variabilidad a la posicion del cuadrado
     rect(i*rectSize/2, j*rectSize/2 + offset, rectSize/2, rectSize/2);
   }
  }
}
