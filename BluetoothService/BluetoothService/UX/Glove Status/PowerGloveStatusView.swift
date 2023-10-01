import SwiftUI

struct PowerGloveStatusView: View {
    let gloveState: PowerGloveDataObject

    enum Constants {
        static let fingerSensorWidth = 25.0
        static let fingerSensorHeight = 180.0

        static let letterButtonSize = 80.0
    }

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Rectangle().frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.fingerSensor1) / 255.0)
                Rectangle().frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.fingerSensor2) / 255.0)
                Rectangle().frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.fingerSensor3) / 255.0)
                Rectangle().fill(.gray).opacity(0.5).frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight)
            }

            HStack {
                Spacer()
                HStack {
                    CircleDialView(value: gloveState.gyroX, maxValue: 256)
                    CircleDialView(value: gloveState.gyroY, maxValue: 256)

                    CircleDialView(value: gloveState.gyroZ, maxValue: 256)
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Rectangle().fill(.red).frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.accelX) / 255.0)
                    Rectangle().fill(.blue).frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.accelY) / 255.0)
                    Rectangle().fill(.green).frame(width: Constants.fingerSensorWidth, height: Constants.fingerSensorHeight * Double(gloveState.accelZ) / 255.0)
                }
                Spacer()
                //            Group {
                //                Text("Thumb: \(gloveState.fingerSensor1)")
                //                Text("Index \(gloveState.fingerSensor2)")
                //                Text("Middle \(gloveState.fingerSensor3)")
                //                Text("Ring not working").strikethrough().disabled(true)
                //                Text("GyroX: \(gloveState.gyroX)")
                //                Text("GyroY: \(gloveState.gyroY)")
                //                Text("GyroZ: \(gloveState.gyroZ)")
                //                Text("AccelerometerX: \(gloveState.accelX)")
                //                Text("AccelerometerY: \(gloveState.accelY)")
                //                Text("AccelerometerZ: \(gloveState.accelZ)")
                //            }
            }.frame(height: Constants.fingerSensorHeight)
            HStack {
                LetterButtonView(color: .red, text: "A", size: 80, isPressed: gloveState.button2State)
                LetterButtonView(color: .yellow, text: "B", size: 80, isPressed: gloveState.button3State)
                LetterButtonView(color: .green, text: "C", size: 80, isPressed: gloveState.button1State)
            }
        }

    }
}

struct PowerGloveStatusView_Previews: PreviewProvider {
    static var previews: some View {
        PowerGloveStatusView(gloveState:
                                PowerGloveDataObject(
                                    fingerSensor1: 100,
                                    fingerSensor2: 98,
                                    fingerSensor3: 32,
                                    button1State: true,
                                    button2State: false,
                                    button3State: false,
                                    gyroX: 34,
                                    gyroY: 12,
                                    gyroZ: 32,
                                    accelX: 12,
                                    accelY: 56,
                                    accelZ: 12))
    }
}
