import Foundation
import Combine

// Robit:
// +Represents a version of Robit
// +Agnostic to if it is physical or Virtual
// +Updates happen externally



class RobitBrain: ObservableObject {
    // As Complexity grows, more parameters will be added


    @Published var state = RobitState(position: SIMD3<Float>.zero, orientation: SIMD3<Float>.zero)

    //TODO: Refactor Command to be Objective
    @Published var command: Command? = nil

    @Published var motorSpeed = MotorOutput(motor1: 0, motor2: 0)


    init(controlLogic: @escaping (RobitState, Command?) -> (MotorOutput),
         objectiveLogic: @escaping (RobitState, Command?) -> (Command?)) {

        $state
            .combineLatest($command)
            .map { controlLogic($0, $1)}
            .assign(to: &$motorSpeed)

        $state
            .combineLatest($command)
            .map { objectiveLogic($0, $1) }
            .assign(to: &$command)

    }
}
