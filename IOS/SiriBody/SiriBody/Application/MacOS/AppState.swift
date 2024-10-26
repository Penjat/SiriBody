import Foundation
import Combine

class AppState: ObservableObject {

    @Published var virtualRobitBrain: RobitBrain!
    @Published var sceneKitInteractor = SceneKitService()
    @Published var pidController = MotionOutputController()
    @Published var sequenceController = SequenceController()

    // Service
    let centralService = CentralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)

    var bag = Set<AnyCancellable>()

    init() {

        // Just return 0 for now
        let controlLogic:  (RobitState?, Command?) -> MotorOutput? = { [weak self] state, command -> MotorOutput? in
            guard let self, let state else {
                return nil
            }
            switch command {
            case .moveTo(x: let x, z: let z):
                pidController.mode = .moveTo((x: x, z: z))

            case nil:
                pidController.mode = .idle
            default:
                break;
            }
            let speed = pidController.motorSpeeds(robitState: state)
            return speed
        }

        // just return origional command for now
        let commandLogic:  (RobitState?, Command?) -> Command? = { [weak self] state, command -> Command? in
            guard let self, let state, let command else {
                return nil
            }

            switch pidController.mode {
            case .moveTo(let position):
                if approximatelyEqual(position.z, Double(state.position.z), tolerance: 0.2),
                   approximatelyEqual(position.x, Double(state.position.x), tolerance: 0.2) {
                    return nil
                }
            default:
                break
            }
            return command
        }

        self.virtualRobitBrain = RobitBrain(
            controlLogic: controlLogic,
            commandLogic: commandLogic)

        setUpSubscriptions()
    }

    private func setUpSubscriptions() {

        // Connect to Phone
        centralService.centralState.sink { [weak self] state in
            switch state {
            case .unknown:
                print("Unkown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("poweredOff")
            case .poweredOn:
                print("poweredOn")
                self?.centralService.retrievePeripheral()
            @unknown default:
                print("unkown")
            }
        }.store(in: &bag)

        // Phone Input to Real RobitState
        centralService
            .inputSubject
            .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true)
            .compactMap { data -> RobitState? in
                guard let state = StateData.createFrom(data: data) else {
                    return nil
                }
                switch state {
                case .positionOrientation(devicePosition: let position, deviceOrientation: let orientation):
                    return RobitState(position: position, orientation: orientation)
                }

            }.assign(to: &sceneKitInteractor.$realRobitState)

        // RobitBrain to VirtualBody
        virtualRobitBrain
            .$motorSpeed
            .assign(to: &sceneKitInteractor.virtualRobitBody.$motorSpeed)

        // VirtualBody to RobitBrain
        sceneKitInteractor
            .virtualRobitBody
            .$state
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .assign(to: &virtualRobitBrain.$state)
    }
}
