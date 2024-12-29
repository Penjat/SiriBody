import Foundation
import Combine


class AppState: ObservableObject {

    // State
    @Published var transmitDevicePosition = true
    
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

        setUpSubscriptions()
    }

    func setUpSubscriptions() {

//        // Realitykit state
        realityKitService
            .realityKitStateSubject
            .assign(to: &$realityKitState)
//
//        // Process Incomming Command form bluetooth
        peripheralService
            .inputSubject
            .compactMap { Command.createFrom(data: $0) }
            .assign(to: &robitBrain.sequenceController.$motionCommand)
        
        peripheralService
            .inputSubject
            .sink{ [weak self] data in
                self?.robitBrain.updateSetting(data: data)
            }.store(in: &bag)
//
//        // RobitBrain process new state
        realityKitService
            .realityKitStateSubject
            .map { RobitState(position: $0.devicePosition,
                              orientation: $0.deviceOrientation,
                              linearVelocity: $0.linearVelocity,
                              gravity: $0.gravity)}
            .assign(to: &robitBrain.$state)

//        // Transmit Robit State
        robitBrain
            .$state
            .compactMap { [weak self] in self?.transmitDevicePosition ?? false ? $0 : nil}
            .compactMap { state -> Data? in StateData.positionOrientation(devicePosition: state.position, deviceOrientation: state.orientation).toData() }
            .subscribe(peripheralService.outputSubject)
            .store(in: &bag)
        
//        // Send output to wheels
        robitBrain
            .$motorSpeed
            .compactMap { TransferService.bluetoothMessageFor(motorOutput: $0) }
            .subscribe(centralService.outputSubject)
            .store(in: &bag)
    
    }
}
