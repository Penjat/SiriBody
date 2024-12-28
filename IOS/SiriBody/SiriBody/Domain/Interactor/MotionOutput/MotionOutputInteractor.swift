import Foundation
import Combine

typealias Position = (x: Double, z: Double)


class MotionOutputInteractor: ObservableObject {

    enum Mode {

        case idle
        case facePosition(Position)
        case faceAngle(Double)
        case moveTo(Position)

        var name: String {
            switch self {

            case .idle:
                "idle"
            case .facePosition(( _, _)):
                "facePosition"
            case .faceAngle(_):
                "faceAngle"
            case .moveTo(( _, _)):
                "moveTo"
            }
        }
    }

    @Published var mode = Mode.idle
    @Published var rotationController = PIDController()
    @Published var translationController = PIDController()
    @Published var targetRotation = 0.0

    @Published var motionEnabled = true
    @Published var rotationEnabled = true

    @Published var maxMotorSpeed = 65.0
    @Published var minMotorSpeed = 50.0
    @Published var angleDifference = 0.0
    @Published var currentAngle = 0.0

    @Published var moveThreshold = 0.5

    var bag = Set<AnyCancellable>()

    init() {
        rotationController.maxValue = 150
        translationController.maxValue = 95
        $mode.sink { [weak self] _ in
            guard let self else {
                return
            }
            // reset errors on controllers
            rotationController.resetError()
            translationController.resetError()
        }.store(in: &bag)
    }

    func calculateShortestDistance(currentAngle: Double, desiredHeading: Double) -> Double {
        let leftDistance = desiredHeading - currentAngle
        let rightDistance = (leftDistance >= 0) ? leftDistance-Double.pi*2 : leftDistance+Double.pi*2

        return abs(leftDistance) < abs(rightDistance) ? leftDistance : rightDistance
    }

    func levelsFor(faceAngel targetRotation: Double, robitState: RobitState) -> MotorOutput {
        // This might need to be changed agian for digital
        currentAngle = Double(robitState.orientation.z)//+(Double.pi/2)


        // Calculate the angle component
        let angleDifference = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)
        let rotationoutput = rotationController.output(angleDifference)

        let motor1SpeedDouble = -(rotationEnabled ? rotationoutput.combined : 0.0)
        let motor2SpeedDouble = (rotationEnabled ? rotationoutput.combined : 0.0)

        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))

        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    }

    func levelsFor(facePosition position: Position, robitState: RobitState ) -> MotorOutput {

        let deltaX = Double(robitState.position.x) - position.x
        let deltaZ = Double(robitState.position.z) - position.z
        currentAngle = Double(robitState.orientation.x)+(Double.pi/2)


        // Calculate the angle component
        targetRotation = atan2(deltaZ, deltaX)
        let angleDifference = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)
        let rotationoutput = rotationController.output(angleDifference)

        let motor1SpeedDouble = (rotationEnabled ? rotationoutput.combined : 0.0)
        let motor2SpeedDouble = -(rotationEnabled ? rotationoutput.combined : 0.0)

        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))

        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    }

    func levelsFor(moveTo position: Position, robitState: RobitState ) -> MotorOutput {
        let deltaX = (Double(robitState.position.x) - position.x)
        let deltaZ = (Double(robitState.position.z) - position.z)
        targetRotation = atan2(deltaX, deltaZ)

        currentAngle = Double(robitState.orientation.x)

        // Calculate the angle component

        let angleDifference1 = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)
        let angleDifference2 = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation+(Double.pi))

        let (angleDifference, direction) = abs(angleDifference1) < abs(angleDifference2) ? (angleDifference1, 1.0) : (angleDifference2, -1.0)

        let rotationoutput = rotationController.output(angleDifference)

        // Calculate translation component
        let distance = sqrt(deltaX * deltaX + deltaZ * deltaZ)
        let translationoutput = translationController.output(distance)

        let forwardLevel = (abs(angleDifference) < moveThreshold) ? -translationoutput.combined*direction : 0.0

        let motor1SpeedDouble = (motionEnabled ? forwardLevel : 0.0) + (rotationEnabled ? rotationoutput.combined : 0.0)
        let motor2SpeedDouble = (motionEnabled ? forwardLevel : 0.0) - (rotationEnabled ? rotationoutput.combined : 0.0)

        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))

        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    }

    func motorSpeeds(robitState: RobitState) -> MotorOutput {

        switch mode {
        case .idle:
            return MotorOutput.zero
        case .faceAngle(let angle):
            return levelsFor(faceAngel: angle, robitState: robitState)
        case .facePosition(let position):
            return levelsFor(facePosition: position, robitState: robitState)
        case .moveTo(let position):
            return levelsFor(moveTo: position, robitState: robitState)
        }
    }

    // TODO: make functions for different cases
    // Turn to
    // Move to
    // align with



    //    let translationoutput = translationController.output(Double(distance))
    //
    //let translationoutput = translationController.output(Double(distance))
    //    //Nedd to multiply by forward ratio
    //    let motor1SpeedDouble = (motionEnabled ? translationoutput.combined : 0.0) + (rotationEnabled ? rotationoutput.combined : 0.0)
    //    let motor2SpeedDouble = (motionEnabled ? translationoutput.combined : 0.0) - (rotationEnabled ? rotationoutput.combined : 0.0)
    //    func motorSpeedsTurnTo

    //    func motorSpeeds2(robitState: RobitState) -> MotorOutput {
    //        guard let target else {
    //            return MotorOutput.zero
    //        }
    //
    //        // Timing
    //        let currentTime = Date()
    //        let deltaTime: Double
    //        if let lastTime = lastUpdateTime {
    //            deltaTime = currentTime.timeIntervalSince(lastTime)
    //        } else {
    //            deltaTime = 0.0
    //        }
    //        lastUpdateTime = currentTime
    //
    //
    //        // Calculate the angle component
    //        currentAngle = Double(robitState.orientation.x)+(Double.pi/2)
    //        let deltaX = Double(robitState.position.x) - target.x
    //        let deltaZ = Double(robitState.position.z) - target.z
    //
    //        targetRotation = atan2(deltaZ, deltaX)
    //        let angleDifference = calculateShortestDistance(currentAngle: currentAngle, desiredHeading: targetRotation)
    //
    //        let errorAngle = angleDifference
    //        integralAngle += errorAngle * deltaTime
    //        let derivativeAngle = deltaTime > 0 ? (errorAngle - lastErrorAngle) / deltaTime : 0.0
    //
    //        let outputAngle =
    //        (pAngleIsOn ? kpAngle * errorAngle: 0.0) +
    //        (iAngleIsOn ? kiAngle * integralAngle: 0.0) +
    //        (dAngleIsOn ? kdAngle * derivativeAngle: 0.0)
    //
    //        lastErrorAngle = errorAngle
    //
    //        turnSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, outputAngle))
    //
    //
    //
    //        // Calculate translation component
    //        let distance = sqrt(deltaX * deltaX + deltaZ * deltaZ)
    //        guard distance > 0.02 else {
    //            self.target = nil
    //            return MotorOutput.zero
    //        }
    //        let forwardRatio = ((angleDifference+(Double.pi/2)).truncatingRemainder(dividingBy: (Double.pi/2)))/(Double.pi/2)
    //
    //        let errorDistance = distance
    //        integralDistance += errorDistance * deltaTime
    //        let derivativeDistance = deltaTime > 0 ? (errorDistance - lastErrorDistance) / deltaTime : 0.0
    //        outputDistance =
    //        ((pDistanceIsOn ? kpDistance * errorDistance : 0.0) +
    //        (iDistanceIsOn ? kiDistance * integralDistance: 0.0) +
    //        (dDistanceIsOn ? kdDistance * derivativeDistance: 0.0))*forwardRatio
    //        lastErrorDistance = errorDistance
    //
    //        let forwardSpeed = max(-maxMotorSpeed, min(maxMotorSpeed, outputDistance))
    //
    //
    //
    //        let motor1SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) + (rotationEnabled ? turnSpeed : 0.0)
    //        let motor2SpeedDouble = (motionEnabled ? forwardSpeed : 0.0) - (rotationEnabled ? turnSpeed : 0.0)
    //
    //        // Limit motor speeds to the allowable range
    //        let limitedMotor1Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor1SpeedDouble)))
    //        let limitedMotor2Speed = Int(max(-maxMotorSpeed, min(maxMotorSpeed, motor2SpeedDouble)))
    //
    //        return MotorOutput(motor1: limitedMotor1Speed, motor2: limitedMotor2Speed)
    //    }
}
