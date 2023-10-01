import Foundation
import Combine

struct PowerGloveDataObject {
    let fingerSensor1: UInt8
    let fingerSensor2: UInt8
    let fingerSensor3: UInt8
    let button1State: Bool
    let button2State: Bool
    let button3State: Bool
    let gyroX: UInt8
    let gyroY: UInt8
    let gyroZ: UInt8
    let accelX: UInt8
    let accelY: UInt8
    let accelZ: UInt8

    init(fingerSensor1: UInt8, fingerSensor2: UInt8, fingerSensor3: UInt8, button1State: Bool, button2State: Bool, button3State: Bool, gyroX: UInt8, gyroY: UInt8, gyroZ: UInt8, accelX: UInt8, accelY: UInt8, accelZ: UInt8) {
        self.fingerSensor1 = fingerSensor1
        self.fingerSensor2 = fingerSensor2
        self.fingerSensor3 = fingerSensor3
        self.button1State = button1State
        self.button2State = button2State
        self.button3State = button3State
        self.gyroX = gyroX
        self.gyroY = gyroY
        self.gyroZ = gyroZ
        self.accelX = accelX
        self.accelY = accelY
        self.accelZ = accelZ
    }

    static func initWithData(data: Data) -> PowerGloveDataObject? {

        guard data.count >= 12 else {
            print("Received data is too short")
            return nil

        }
        guard data.first == 0x02 && data.last == 0x03 else {
            print("Invalid start or end marker")
            return nil

        }

        let buttonsByte = data[4]

        return PowerGloveDataObject(fingerSensor1: data[1],
                             fingerSensor2: data[2],
                             fingerSensor3: data[3],
                             button1State: (buttonsByte & (1 << 2)) != 0,
                             button2State: (buttonsByte & (1 << 1)) != 0,
                             button3State: (buttonsByte & 1) != 0,
                             gyroX: data[5],
                             gyroY: data[6],
                             gyroZ: data[7],
                             accelX: data[8],
                             accelY: data[9],
                             accelZ: data[10])
    }
}
