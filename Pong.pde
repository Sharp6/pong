/*
Serial String Reader 
Language: Processing

reads in a string of characters from a serial port until it gets a linefeed (ASCII 10).
Then splits the string into sections separated by commas. 
Then converts the sections to ints, and prints them out. 
*/

// import the Processing serial library
import processing.serial.*;

// Linefeed in ASCII
int linefeed = 10; 
// The serial port
// Serial myPort;

float leftPaddle, rightPaddle;      // variables for the flex sensor values 
int resetButton, serveButton;       // variables for the button values 
int leftPaddleX, rightPaddleX;      // horizontal positions of the paddles 

int paddleHeight = 50;              // vertical dimension of the paddles
int paddleWidth  = 10;              // horizontal dimension of the paddles

float leftMinimum  = 250;   // minimum value of the left flexsensor 
float rightMinimum = 260;   // minimum value of the right flexsensor 
float leftMaximum  = 450;   // maximum value of the left flexsensor 
float rightMaximum = 460;   // maximum value of the right flexsensor

// Ball vars
int ballSize = 10;             // the size of the ball 
int xDirection = 1;            // the ball's horizontal direction.
                               // left is –1, right is 1.
int yDirection = 1;            // the ball's vertical direction. 
                               // up is –1, down is 1. 
int xPos, yPos;                // the ball's horizontal and vertical positions
boolean ballInMotion = false;  // whether the ball should be moving 

int leftScore  = 0;
int rightScore = 0;

// Font stuff
PFont myFont;
int fontSize = 36;

void setup() {
  // set the window size: 
  size(640, 480);
  
  // List all the available serial ports 
  println(Serial.list());

  // I know that the first port in the serial list on my mac 
  // is always my Arduino module, so I open Serial.list()[0]. 
  // Change the 0 to the appropriate number of the serial port 
  // that your microcontroller is attached to.
  
  // myPort = new Serial(this, Serial.list()[0], 9600);
  
  // read bytes into a buffer until you get a linefeed (ASCII 10):
  // myPort.bufferUntil(linefeed); 
  
  // initialize the ball in the center of the screen: 
  xPos = width /2;
  yPos = height/2;
  
  // initialize the sensor values: 
  leftPaddle = height/2; 
  rightPaddle = height/2; 
  
  resetButton = 0;
  serveButton = 0;

  // initialize the horizontal paddle positions: 
  leftPaddleX = 50;
  rightPaddleX = width - 50;

  // set no borders on drawn shapes:
  noStroke();
  
  // create a font with the third font available to the system: 
  PFont myFont = createFont(PFont.list()[2], fontSize); 
  textFont(myFont);
}

void draw() {
  background(0);
  
  // draw the left paddle:
  rect(leftPaddleX, leftPaddle, paddleWidth, paddleHeight);
  // draw the right paddle:
  rect(rightPaddleX, rightPaddle, paddleWidth, paddleHeight);
  
  // calculate the ball's position and draw it: 
  if (ballInMotion == true) {
    animateBall(); 
  }

  // if the serve button is pressed, start the ball moving: 
  if (serveButton == 1) {
    ballInMotion = true; 
  }

  // if the reset button is pressed, reset the scores // and start the ball moving:
  if (resetButton == 1) {
    leftScore = 0; 
    rightScore = 0; 
    ballInMotion = true;
  }
  
  // print the scores:
  text(leftScore, fontSize, fontSize); 
  text(rightScore, width-fontSize, fontSize);
}

// serialEvent method is run automatically by the Processing sketch 
// whenever the buffer reaches the byte value set in the bufferUntil() 
// method in the setup():

/*
void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil(linefeed);
  // if you got any bytes other than the linefeed:
  if (myString != null) {
    myString = trim(myString);
    // split the string at the commas
    // and convert the sections into integers:
    int sensors[] = int(split(myString, ','));
    
    // print out the values you got:
    for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
      print("Sensor " + sensorNum + ": " + sensors[sensorNum] + "\t"); 
    }
    
    // add a linefeed after all the sensor values are printed:
    println(); 
  }
}
*/

/*
void serialEvent(Serial myPort) {
  // read the serial buffer:
  String myString = myPort.readStringUntil(linefeed);
  
  // if you got any bytes other than the linefeed: 
  if (myString != null) {
    myString = trim(myString);
    // split the string at the commas
    //and convert the sections into integers: 
    int sensors[] = int(split(myString, ','));
    
    // if you received all the sensor strings, use them: 
    if (sensors.length == 4) {
      // calculate the flex sensors' ranges:
      float leftRange = leftMaximum - leftMinimum; 
      float rightRange = rightMaximum - rightMinimum;

      // scale the flex sensors' results to the paddles' range: 
      leftPaddle = height * (sensors[0] - leftMinimum) / leftRange; 
      rightPaddle = height * (sensors[1] - rightMinimum) / rightRange;

      // assign the switches' values to the button variables: 
      resetButton = sensors[2];
      serveButton = sensors[3];

      // print the sensor values:
      print("left: "+ leftPaddle + "\tright: " + rightPaddle); 
      println("\treset: "+ resetButton + "\tserve: " + serveButton);
     } 
   }
}
*/

void animateBall() {
  // if the ball is moving left: 
  if (xDirection < 0) {
    // if the ball is to the left of the left paddle: 
    if ((xPos<=leftPaddleX)) {
      // if the ball is in between the top and bottom 
      // of the left paddle:
      if((leftPaddle - (paddleHeight/2) <= yPos) && (yPos <= leftPaddle + (paddleHeight /2))) { 
        // reverse the horizontal direction: 
        xDirection = -xDirection;
      } 
    }
  }
  
  // if the ball is moving right: 
  else {
    // if the ball is to the right of the right paddle: 
    if (( xPos >= (rightPaddleX + ballSize/2 ))) {
      // if the ball is in between the top and bottom 
      // of the right paddle:
      if(( rightPaddle - (paddleHeight/2) <=yPos) && (yPos <= rightPaddle + (paddleHeight /2))) {
        // reverse the horizontal direction:
        xDirection = -xDirection; 
      }
    } 
  }

  // if the ball goes off the screen left: 
  if(xPos<0){
    rightScore++;
    resetBall(); 
  }

  // if the ball goes off the screen right: 
  if (xPos > width) {
    leftScore++;
    resetBall(); 
  }

  // stop the ball going off the top or the bottom of the screen: 
  if ((yPos - ballSize/2 <= 0) || (yPos +ballSize/2 >=height)) {
    // reverse the y direction of the ball:
    yDirection = -yDirection; 
  }
  
  // update the ball position: 
  xPos = xPos + xDirection; yPos = yPos + yDirection;

  // Draw the ball:
  rect(xPos, yPos, ballSize, ballSize); 
}

void resetBall() {
  // put the ball back in the center 
  xPos = width /2;
  yPos = height/2;
}
