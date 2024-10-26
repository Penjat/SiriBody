import Foundation
import Combine

// Robit:
// +Represents a version of Robit
// +Agnostic to if it is physical or Virtual
// +Updates happen externally

class RobitBrain: ObservableObject {
    // As Complexity grows, more parameters will be added

    @Published var state = RobitState.zero
    @Published var command: Command? = nil

    @Published var motorSpeed = MotorOutput(motor1: 0, motor2: 0)


    init(controlLogic: @escaping (RobitState, Command?) -> (MotorOutput?),
         commandLogic: @escaping (RobitState, Command?) -> (Command?)) {

        $state
            .combineLatest($command)
            .compactMap { controlLogic($0, $1)}
            .assign(to: &$motorSpeed)

        $state
            .combineLatest($command)
            .map { commandLogic($0, $1) }
            .assign(to: &$command)

    }
}
