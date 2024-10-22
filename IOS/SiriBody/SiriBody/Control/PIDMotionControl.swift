import SwiftUI
import Combine

class PIDMotionControl: ObservableObject {
    @Published var motionEnabled = false
    @Published var rotationEnabled = false
    @Published var target: (x: Double, z: Double)?
    
    // PID constants for distance control
    @Published var kpDistance: Double = 1.0
    @Published var kiDistance: Double = 0.0
    @Published var kdDistance: Double = 0.0
    
    @Published var pDistanceIsOn = true
    @Published var iDistanceIsOn = true
    @Published var dDistanceIsOn = true
    
    // PID constants for angle control
    @Published var kpAngle: Double = 1.0
    @Published var kiAngle: Double = 0.0
    @Published var kdAngle: Double = 0.0
    
    @Published var pAngleIsOn = true
    @Published var iAngleIsOn = true
    @Published var dAngleIsOn = true
    
    @Published var maxMotorSpeed = 95.0      // Maximum motor speed
    @Published var minMotorSpeed = 50.0       // Minimum motor speed to overcome inertia
    
    // Internal variables for PID calculations
    private var integralDistance: Double = 0.0
    private var lastErrorDistance: Double = 0.0
    
    private var integralAngle: Double = 0.0
    private var lastErrorAngle: Double = 0.0
    
    private var lastUpdateTime: Date?
    
    var bag = Set<AnyCancellable>()
    
    init() {
        $target.sink { _ in
            self.lastErrorAngle = 0.0
            self.lastErrorDistance = 0.0
            self.lastUpdateTime = .now
        }.store(in: &bag)
    }
    
    func motorSpeeds(robitState: RobitState) -> MotorOutput {
        guard let target else {
            return MotorOutput.zero
        }
        
        let currentTime = Date()
        let deltaTime: Double
        if let lastTime = lastUpdateTime {
            deltaTime = currentTime.timeIntervalSince(lastTime)
        } else {
            deltaTime = 0.0
        }
        lastUpdateTime = currentTime
        
        // Calculate the vector from the current position to the target position
        let deltaX = target.x - Double(robitState.position.x)
        let deltaZ = target.z - Double(robitState.position.z)

        // Calculate the distance to the target
        let distance = sqrt(deltaX * deltaX + deltaZ * deltaZ)
        guard distance > 0.02 else {
            self.target = nil
            return MotorOutput.zero
        }
        
        // Calculate the desired heading (angle) to the target
        let desiredHeading = atan2(deltaZ, deltaX) // In radians

        // Calculate the smallest difference between the desired heading and current yaw
        let currentAngle = Double(robitState.orientation.z)+(Double.pi/2)

        var angleDifference = desiredHeading - currentAngle
        // Normalize the angle difference to be within -π to π
        angleDifference = atan2(sin(angleDifference), cos(angleDifference))


        let forwardRatio = (currentAngle-desiredHeading+Double.pi/2)/(Double.pi/2)
        // PID control for distance
        let errorDistance = distance
        integralDistance += errorDistance * deltaTime
        let derivativeDistance = deltaTime > 0 ? (errorDistance - lastErrorDistance) / deltaTime : 0.0

        let outputDistance =
        ((pDistanceIsOn ? kpDistance * errorDistance : 0.0) +
        (iDistanceIsOn ? kiDistance * integralDistance: 0.0) +
        (dDistanceIsOn ? kdDistance * derivativeDistance: 0.0))*forwardRatio

        lastErrorDistance = errorDistance

        // PID control for angle
        let errorAngle = angleDifference
        integralAngle += errorAngle * deltaTime
        let derivativeAngle = deltaTime > 0 ? (errorAngle - lastErrorAngle) / deltaTime : 0.0

        let outputAngle =
        (pAngleIsOn ? kpAngle * errorAngle: 0.0) +
        (iAngleIsOn ? kiAngle * integralAngle: 0.0) +
        (dAngleIsOn ? kdAngle * derivativeAngle: 0.0)

        lastErrorAngle = errorAngle

        var forwardSpeed = outputDistance
        var turnSpeed = outputAngle

        // Limit the forward speed
        forwardSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, forwardSpeed))

        // Ensure the forward speed is at least the minimum motor speed if moving
//        if abs(forwardSpeed) > 0 && abs(forwardSpeed) < minMotorSpeed {
//            forwardSpeed = forwardSpeed >= 0 ? minMotorSpeed : -minMotorSpeed
//        }

        // Limit the turn speed
        turnSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, turnSpeed))

        // Calculate motor speeds based on forward and turn speeds
        let motor1SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) - (rotationEnabled ? turnSpeed : 0.0)
        let motor2SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) + (rotationEnabled ? turnSpeed : 0.0)

        // Limit motor speeds to the allowable range
        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))
        
        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    }
}
