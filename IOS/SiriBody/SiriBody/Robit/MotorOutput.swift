import Foundation

struct MotorOutput {
    let motor1: Int
    let motor2: Int

    static var zero: MotorOutput {
        MotorOutput(motor1: 0, motor2: 0)
    }
}
