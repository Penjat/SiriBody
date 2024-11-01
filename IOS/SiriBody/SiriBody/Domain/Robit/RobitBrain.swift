import Foundation
import Combine

// Robit:
// +Represents a version of Robit
// +Agnostic to if it is physical or Virtual
// +Updates happen externally

class RobitBrain: ObservableObject {
    // As Complexity grows, more parameters will be added
    @Published var objectiveInteractor: ObjectiveInteractor!
    @Published var motionController = MotionOutputInteractor()
    @Published var sequenceController = CommandInteractor()
    @Published var state = RobitState.zero
    @Published var mapController = RobitMap()

    @Published var motorSpeed = MotorOutput(motor1: 0, motor2: 0)
    var bag = Set<AnyCancellable>()

    init() {
        // Give Objectiveinteractor
        objectiveInteractor = ObjectiveInteractor(
            statePublisher: 
                mapController
                .$robitGridPosition
                .compactMap { $0 }
                .eraseToAnyPublisher(),
            robitMap:
                mapController
        )

        // Everytime there is a new state
        // check if our motion command is complete
        // return the motor speed
        $state
            .compactMap { [weak self] state -> MotorOutput?  in

                guard let self else {
                    return nil
                }
                switch motionController.mode {

                case .moveTo(let position):
                    if approximatelyEqual(position.z, Double(state.position.z), tolerance: 0.2),
                       approximatelyEqual(position.x, Double(state.position.x), tolerance: 0.2) {
                        sequenceController.stepComplete()
                    }
                default:
                    return nil
                }

                return motionController.motorSpeeds(robitState: state)
            }
            .assign(to: &$motorSpeed)

        // Everytime there is a new command
        // check if should send to motion controller
        sequenceController
            .$motionCommand
            .sink { [weak self] command  in

                guard let self else {
                    return
                }
                switch command {
                case .moveTo(x: let x, z: let z):
                    motionController.mode = .moveTo((x: x, z: z))

                case nil:
                    motionController.mode = .idle
                default:
                    break;
                }
            }.store(in: &bag)

        $state
            .map { GridPosition(
                x: Int($0.position.x),
                z: Int($0.position.z))  }
            .removeDuplicates()
            .assign(to: &mapController.$robitGridPosition)
    }
}
