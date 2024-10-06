import Foundation
import Combine

class AppState: ObservableObject {
    let centralService: CentralService
    
    @Published var movementInteractor: MovementInteractor
    
    var bag = Set<AnyCancellable>()
    
    init() {
        let service = CentralService(serviceID: TransferService.siriBodyServiceUUID, charID: TransferService.siriBodyCharUUID)
        self.centralService = service
        self.movementInteractor = MovementInteractor(mode: .bluetooth(service: service))
        
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
