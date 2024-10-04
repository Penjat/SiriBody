#include <SoftwareSerial.h>

// Motor Driver
#define motor1PinSpeed 3
#define motor1PinA 4
#define motor1PinB 5

#define motor2PinSpeed 10
#define motor2PinA 7
#define motor2PinB 6

#define batterylevelPin A7

// Bluetooth
SoftwareSerial hm10(11, 12);

void setup() {
  // Set up pins
  pinMode(motor1PinA, OUTPUT);
  pinMode(motor1PinB, OUTPUT);
  pinMode(motor2PinA, OUTPUT);
  pinMode(motor2PinB, OUTPUT);

  Serial.begin(9600);
  hm10.begin(9600);
  Serial.println("Starting up...");
  hm10.write("AT");
}

void loop() {
  Serial.println("Begin Test");

  Serial.println("Right On, Left Off");
  digitalWrite(motor1PinA, LOW);
  digitalWrite(motor1PinB, HIGH);
  digitalWrite(motor2PinA, HIGH);
  digitalWrite(motor2PinB, LOW);
  
  analogWrite(motor1PinSpeed, 1020);
  analogWrite(motor2PinSpeed, 1020);

  delay(1000);

  Serial.println("Right Off, Left Off");
  analogWrite(motor1PinSpeed, 0);
  analogWrite(motor2PinSpeed, 0);
  delay(1000);

  Serial.println("Right Off, Left On");
  digitalWrite(motor1PinA, HIGH);
  digitalWrite(motor1PinB, LOW);
  

  digitalWrite(motor2PinA, LOW);
  digitalWrite(motor2PinB, HIGH);
  analogWrite(motor1PinSpeed, 1020);
  analogWrite(motor2PinSpeed, 1020);

  delay(1000);
  Serial.println("Right Off, Left Off");
  analogWrite(motor1PinSpeed, 0);
  analogWrite(motor2PinSpeed, 0);
  
  delay(1000);

  
  
  // if (Serial.available()) {
  //   char input = Serial.read();
  //   hm10.write(input);
  // }

  // if (hm10.available()) {
  //   char btInput = hm10.read();
  //   Serial.write(btInput);
  // }
}
