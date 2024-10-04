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
}

void loop() {


  if (hm10.available() >= 4) {

    byte c = hm10.read();

    if (c == 253) {
      byte motor1Byte = hm10.read();
      byte motor2Byte = hm10.read();
      byte endByte = hm10.read();

      if (endByte == 252) {
        int motor1Speed = (motor1Byte - 100);
        int motor2Speed = (motor2Byte - 100);

        if (motor1Speed == 0) {
          digitalWrite(motor1PinA, LOW);
          digitalWrite(motor1PinB, LOW);
          analogWrite(motor1PinSpeed, 0);

        } else if (motor1Speed > 0) {
          digitalWrite(motor1PinA, HIGH);
          digitalWrite(motor1PinB, LOW);
          
          int motor1Output = map(motor1Speed, 0, 100, 0, 1023);
          analogWrite(motor1PinSpeed, motor1Output);

        } else {
          digitalWrite(motor1PinA, LOW);
          digitalWrite(motor1PinB, HIGH);

          int motor1Output = map(motor1Speed, 0, -100, 0, 1023);
          analogWrite(motor1PinSpeed, motor1Output);
        }

        if (motor2Speed == 0) {
          digitalWrite(motor2PinA, LOW);
          digitalWrite(motor2PinB, LOW);
          analogWrite(motor2PinSpeed, 0);

        } else if (motor2Speed > 0) {
          digitalWrite(motor2PinA, HIGH);
          digitalWrite(motor2PinB, LOW);

          int motor2Output = map(motor2Speed, 0, 100, 0, 1023);
          analogWrite(motor2PinSpeed, motor2Output);

        } else {
          digitalWrite(motor2PinA, LOW);
          digitalWrite(motor2PinB, HIGH);
          
          int motor2Output = map(motor2Speed, 0, -100, 0, 1023);
          analogWrite(motor2PinSpeed, motor2Output);
        }

      } else {
        Serial.println(endByte);
      }
    } else {
      Serial.println(c);
    }
  }
}
