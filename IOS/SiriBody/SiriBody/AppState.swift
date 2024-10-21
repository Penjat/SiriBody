import Foundation
import Combine

class AppState: ObservableObject {

    // State
    @Published var transmitDevicePosition = false

    @Published var realityKitState = RealityKitState.zero
    @Published var motionEnabled = false

    // Service
    let centralService = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
    let peripheralService = PeripheralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    let motionService = MotionService()
    let realityKitService = RealityKitService()

    // Interactor
    @Published var movementInteractor: MovementInteractor
    @Published var goalInteractor = GoalInteractor()

    // Control
    @Published var pidControl = PIDRotationControl()
    @Published var pidMotionControl = PIDMotionControl()

    var bag = Set<AnyCancellable>()

    init() {
        self.movementInteractor = MovementInteractor(mode: .bluetooth(service: centralService))

        //        motionService.startPositionUpdates()

    }

    func setUpSubscriptions() {
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

        realityKitService
            .realityKitStateSubject
            .assign(to: &$realityKitState)


        peripheralService
            .inputSubject
            .compactMap { Command.createFrom(data: $0) }
            .assign(to: &goalInteractor.$command)


        realityKitService
            .realityKitStateSubject
            .map { RobitState(position: $0.devicePosition,
                              orientation: $0.deviceOrientation,
                              linearVelocity: $0.linearVelocity,
                              gravity: $0.gravity)}
            .sink { [weak self] state in

            guard let self, let command = goalInteractor.command, motionEnabled else {
                return
            }
            switch command {
            case .turnTo(angle: _):
                let turnVector = pidControl.motorOutput(currentYaw: Double(state.orientation.z))
                print(turnVector)

                let forwardBackward = 0.0
                let leftRight = max(-254,min(254,(turnVector)))

                let motor1Speed = max(-254,min(254,(forwardBackward - leftRight)))
                let motor2Speed = max(-254,min(254,(forwardBackward + leftRight)))

                if motionEnabled {
                    movementInteractor.motorSpeed = (motor1Speed: Int(motor1Speed), motor2Speed: Int(motor2Speed))
                }

            case .moveTo(x: _, z: _):
                if motionEnabled {
                    movementInteractor.motorSpeed = pidMotionControl.motorSpeeds(robitState: state)
                }
                break
            }

        }.store(in: &bag)


        //            .$robitState.compactMap{ $0 }.sink { state in
        //
        //            peripheralService.outputSubject.send(StateData.positionOrientation(devicePosition: state.devicePosition, deviceOrientation: state.deviceOrientation).toData())
        //        }.store(in: &bag)
    }
}
