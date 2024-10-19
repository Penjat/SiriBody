import Foundation
import Combine

class AppState: ObservableObject {
    let centralService = CentralService(serviceID: TransferService.phoneServiceUUID, charID: TransferService.phoneCharUUID)
    let robitPositionService = RobitPositionService()
    let sceneKitInteractor = SceneKitInteractor()
    let virtualRobitInteractor = VirtualRobitInteractor()
    
    var bag = Set<AnyCancellable>()
    
    init() {
        
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
