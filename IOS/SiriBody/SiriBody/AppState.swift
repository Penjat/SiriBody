import Foundation
import Combine

class AppState: ObservableObject {
    let centralService = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
    let peripheralService = PeripheralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    let motionService = MotionService()
//    let locationService = LocationService()
    let goalInteractor = GoalInteractor()
    let robitStateService = RobitStateService()
    let realityKitService = RealityKitService()

    @Published var movementInteractor: MovementInteractor
    
    var bag = Set<AnyCancellable>()
    
    init() {
        self.movementInteractor = MovementInteractor(mode: .bluetooth(service: centralService))
        realityKitService.$deviceOrientation.sink { [weak self] orientation in
            self?.robitStateService.state = RobitState(pitch: Double(orientation.x), roll: Double(orientation.y), yaw: Double(orientation.z))
        }.store(in: &bag)
        motionService.startPositionUpdates()
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
    }
}
