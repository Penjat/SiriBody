import Foundation
import Combine

// Robit:
// +Represents a version of Robit
// +Agnostic to if it is physical or Virtual
// +Updates happen externally

class RobitBrain: ObservableObject {
    // As Complexity grows, more parameters will be added
    @Published var motionController = MotionOutputController()
    @Published var sequenceController = SequenceController()
    @Published var state = RobitState.zero

    @Published var motorSpeed = MotorOutput(motor1: 0, motor2: 0)
    var bag = Set<AnyCancellable>()

    init() {

        // Everytime there is a new command
        // check if should send to motion controller
        $state
            .combineLatest(sequenceController.$motionCommand)
            .compactMap { [weak self] (state, command) -> MotorOutput?  in

                guard let self else {
                    return nil
                }
                switch command {
                case .moveTo(x: let x, z: let z):
                    motionController.mode = .moveTo((x: x, z: z))

                case nil:
                    motionController.mode = .idle
                default:
                    break;
                }
                return motionController.motorSpeeds(robitState: state)
            }
            .assign(to: &$motorSpeed)


        sequenceController
            .$motionCommand
            .combineLatest($state)
            .sink { [weak self] (command, state)  in

                guard let self, let command else {
                    return
                }
                switch motionController.mode {

                case .moveTo(let position):
                    if approximatelyEqual(position.z, Double(state.position.z), tolerance: 0.2),
                       approximatelyEqual(position.x, Double(state.position.x), tolerance: 0.2) {
                        sequenceController.stepComplete()
                    }
                default:
                    return
                }
            }.store(in: &bag)

    }
}
