#include <SoftwareSerial.h>

// Motor Driver
#define motor1PinSpeed 3
#define motor1PinA 4
#define motor1PinB 5

#define motor2PinSpeed 10
#define motor2PinA 7
#define motor2PinB 6

#define batterylevelPin A7

#define acceleration 0.0035

unsigned long previousTime = 0;
unsigned long deltaTime = 0;

// Bluetooth
SoftwareSerial hm10(11, 12);

int motor1Level = 0;
int motor1TargetLevel = 0;

int motor2Level = 0;
int motor2TargetLevel = 0;

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
  
  checkBluetooth();

  unsigned long currentTime = micros();
  deltaTime = currentTime - previousTime;  // Calculate the time difference in microseconds
  previousTime = currentTime;
  updateMotorOutput(deltaTime);
}

bool approximatelyEqual(float a, float b, float epsilon = 0.001) {
  return abs(a - b) <= epsilon;
}

void updateMotorOutput(unsigned long deltaTime) {
  if (approximatelyEqual(motor1Level, motor1TargetLevel) == true) {
    motor1Level = motor1TargetLevel;
  } else if (motor1Level < motor1TargetLevel) {
    motor1Level += acceleration * deltaTime;
  } else if (motor1Level > motor1TargetLevel) {
    motor1Level -= acceleration * deltaTime;
  }

  if (approximatelyEqual(motor2Level, motor2TargetLevel) == true) {
    motor2Level = motor2TargetLevel;
  } else if (motor2Level < motor2TargetLevel) {
    motor2Level += acceleration * deltaTime;
  } else if (motor2Level > motor2TargetLevel) {
    motor2Level -= acceleration * deltaTime;
  }

  analogWrite(motor1PinSpeed, motor1Level);
  analogWrite(motor2PinSpeed, motor2Level);
}

void checkBluetooth() {
  if (hm10.available() >= 4) {

    byte c = hm10.read();

    if (c == 253) {
      byte motor1Byte = hm10.read();
      byte motor2Byte = hm10.read();
      byte endByte = hm10.read();

      if (endByte == 252) {
        int motor1Speed = (motor1Byte - 100);
        int motor2Speed = (motor2Byte - 100);

        // Serial.print("Motor 1 Speed: ");
        // Serial.println(motor1Speed);
        // Serial.print("Motor 2 Speed: ");
        // Serial.println(motor2Speed);


        if (motor1Speed == 0) {
          digitalWrite(motor1PinA, LOW);
          digitalWrite(motor1PinB, LOW);
          motor1TargetLevel = 0;

        } else if (motor1Speed > 0) {
          digitalWrite(motor1PinA, HIGH);
          digitalWrite(motor1PinB, LOW);

          motor1TargetLevel = map(motor1Speed, 0, 100, 0, 255);

        } else {
          digitalWrite(motor1PinA, LOW);
          digitalWrite(motor1PinB, HIGH);

          motor1TargetLevel = map(motor1Speed, 0, -100, 0, 255);
        }

        if (motor2Speed == 0) {
          digitalWrite(motor2PinA, LOW);
          digitalWrite(motor2PinB, LOW);
          motor2TargetLevel = 0;

        } else if (motor2Speed > 0) {
          digitalWrite(motor2PinA, HIGH);
          digitalWrite(motor2PinB, LOW);

          motor2TargetLevel = map(motor2Speed, 0, 100, 0, 255);

        } else {
          digitalWrite(motor2PinA, LOW);
          digitalWrite(motor2PinB, HIGH);

          motor2TargetLevel = map(motor2Speed, 0, -100, 0, 255);

        }

      } else {
        // Serial.println(endByte);
      }
    } else {
      // Serial.println(c);
    }
  }
}
