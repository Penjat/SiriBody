import SwiftUI
import Combine

typealias Position = (x: Double, z: Double)

class PIDMotionControl: ObservableObject {
    @Published var motionEnabled = false
    @Published var rotationEnabled = true
    @Published var target: (x: Double, z: Double)?
    
    // PID constants for distance control
    @Published var kpDistance: Double = 700.0
    @Published var kiDistance: Double = 0.0
    @Published var kdDistance: Double = 0.0

    @Published var outputDistance = 0.0
    @Published var turnSpeed = 0.0

    @Published var pDistanceIsOn = true
    @Published var iDistanceIsOn = true
    @Published var dDistanceIsOn = true
    
    // PID constants for angle control
    @Published var kpAngle: Double = 400.0
    @Published var kiAngle: Double = 0.0
    @Published var kdAngle: Double = 0.0
    
    @Published var pAngleIsOn = true
    @Published var iAngleIsOn = true
    @Published var dAngleIsOn = true
    
    @Published var maxMotorSpeed = 95.0      // Maximum motor speed
    @Published var minMotorSpeed = 50.0       // Minimum motor speed to overcome inertia

    @Published var targetRotation = 0.0
    @Published var currentAngle = 0.0

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

    func calculateShortestDistance(currentAngle: Double, desiredHeading: Double) -> Double {
        let leftDistance = desiredHeading - currentAngle
        let rightDistance = (leftDistance >= 0) ? leftDistance-Double.pi*2 : leftDistance+Double.pi*2

        return abs(leftDistance) < abs(rightDistance) ? leftDistance : rightDistance
    }



    func motorSpeeds(robitState: RobitState) -> MotorOutput {

        guard let target else {
            return MotorOutput.zero
        }

        let deltaX = Double(robitState.position.x) - target.x
        let deltaZ = Double(robitState.position.z) - target.z
        currentAngle = Double(robitState.orientation.x)+(Double.pi/2)


        // Calculate the angle component
        targetRotation = atan2(deltaZ, deltaX)
        let angleDifference = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)

        guard !approximatelyEqual(angleDifference, 0.0, tolerance: 0.02) else {
            return MotorOutput.zero
        }


        return (angleDifference > 0) ? MotorOutput(motor1: 1, motor2: -1) : MotorOutput(motor1: -1, motor2: 1)
    }

    func motorSpeeds2(robitState: RobitState) -> MotorOutput {
        guard let target else {
            return MotorOutput.zero
        }

        // Timing
        let currentTime = Date()
        let deltaTime: Double
        if let lastTime = lastUpdateTime {
            deltaTime = currentTime.timeIntervalSince(lastTime)
        } else {
            deltaTime = 0.0
        }
        lastUpdateTime = currentTime


        // Calculate the angle component
        currentAngle = Double(robitState.orientation.x)+(Double.pi/2)
        let deltaX = Double(robitState.position.x) - target.x
        let deltaZ = Double(robitState.position.z) - target.z

        targetRotation = atan2(deltaZ, deltaX)
        let angleDifference = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)

        let errorAngle = angleDifference
        integralAngle += errorAngle * deltaTime
        let derivativeAngle = deltaTime > 0 ? (errorAngle - lastErrorAngle) / deltaTime : 0.0

        let outputAngle =
        (pAngleIsOn ? kpAngle * errorAngle: 0.0) +
        (iAngleIsOn ? kiAngle * integralAngle: 0.0) +
        (dAngleIsOn ? kdAngle * derivativeAngle: 0.0)

        lastErrorAngle = errorAngle

        turnSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, outputAngle))



        // Calculate translation component
        let distance = sqrt(deltaX * deltaX + deltaZ * deltaZ)
        guard distance > 0.02 else {
            self.target = nil
            return MotorOutput.zero
        }
        let forwardRatio = ((angleDifference+(Double.pi/2)).truncatingRemainder(dividingBy: (Double.pi/2)))/(Double.pi/2)

        let errorDistance = distance
        integralDistance += errorDistance * deltaTime
        let derivativeDistance = deltaTime > 0 ? (errorDistance - lastErrorDistance) / deltaTime : 0.0
        outputDistance =
        ((pDistanceIsOn ? kpDistance * errorDistance : 0.0) +
        (iDistanceIsOn ? kiDistance * integralDistance: 0.0) +
        (dDistanceIsOn ? kdDistance * derivativeDistance: 0.0))*forwardRatio
        lastErrorDistance = errorDistance

        let forwardSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, outputDistance))



        let motor1SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) + (rotationEnabled ? turnSpeed : 0.0)
        let motor2SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) - (rotationEnabled ? turnSpeed : 0.0)

        // Limit motor speeds to the allowable range
        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))

        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    }
}
