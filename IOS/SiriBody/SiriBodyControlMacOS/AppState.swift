import Foundation
import Combine

class AppState: ObservableObject {

    @Published var virtualRobitBrain: RobitBrain
    @Published var sceneKitInteractor = SceneKitInteractor()

    // Service
    let centralService = CentralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    //    let robitPositionService: RobitPositionService


    var bag = Set<AnyCancellable>()

    init() {

        // Just return 0 for now
        var controlLogic:  (RobitState?, Command?) -> MotorOutput = { state, command in
            return MotorOutput.zero
        }

        // just return origional command for now
        var objectiveLogic:  (RobitState?, Command?) -> Command? = { state, command in
            return command
        }

        self.virtualRobitBrain = RobitBrain(
            controlLogic: controlLogic,
            objectiveLogic: objectiveLogic)

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

        virtualRobitBrain
            .$motorSpeed
            .assign(to: &sceneKitInteractor.virtualRobit.$motorSpeed)
    }
}
