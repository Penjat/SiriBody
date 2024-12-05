import Foundation
import Combine


class AppState: ObservableObject {

    // State
    @Published var transmitDevicePosition = false

    @Published var realityKitState = RealityKitState.zero
    @Published var motionEnabled = false

    // Control
    @Published var robitBrain = RobitBrain()
    @Published var pidMotionInteractor = MotionOutputInteractor()

    // Service
    let centralService = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
    let peripheralService = PeripheralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    let realityKitService = RealityKitService()

    var bag = Set<AnyCancellable>()

    init() {

        // Just return 0 for now
        let controlLogic:  (RobitState?, Command?) -> MotorOutput? = { [weak self] state, command -> MotorOutput? in
            guard let self, let state else {
                return nil
            }
            switch command {
            case .moveTo(x: let x, z: let z):
                pidMotionInteractor.mode = .moveTo((x: x, z: z))

            default:
                break
            }
            return pidMotionInteractor.motorSpeeds(robitState: state)
        }

        // just return origional command for now
        let commandLogic:  (RobitState?, Command?) -> Command? = { state, command in
            return command
        }

        setUpSubscriptions()
    }

    func setUpSubscriptions() {

//        // Realitykit state
//        realityKitService
//            .realityKitStateSubject
//            .assign(to: &$realityKitState)
//
//        // Process Incomming Command form bluetooth
//        peripheralService
//            .inputSubject
//            .compactMap { Command.createFrom(data: $0) }
//            .assign(to: &robitBrain.$command)
//
//        // RobitBrain process new state
//        realityKitService
//            .realityKitStateSubject
//            .map { RobitState(position: $0.devicePosition,
//                              orientation: $0.deviceOrientation,
//                              linearVelocity: $0.linearVelocity,
//                              gravity: $0.gravity)}
//            .assign(to: &robitBrain.$state)
//
//        // Scan for wheels
        
//
//        // Transmit Robit State
//        //TODO: make sure this works
//        robitBrain
//            .$state
//            .compactMap { [weak self] in self?.transmitDevicePosition ?? false ? $0 : nil}
//            .compactMap { state -> Data? in StateData.positionOrientation(devicePosition: state.position, deviceOrientation: state.orientation).toData() }
//            .subscribe(peripheralService.outputSubject)
//            .store(in: &bag)
//
//        // Send output to wheels
        robitBrain
            .$motorSpeed
            .compactMap { TransferService.bluetoothMessageFor(motorOutput: $0) }
            .subscribe(centralService.outputSubject)
            .store(in: &bag)
    }
}
