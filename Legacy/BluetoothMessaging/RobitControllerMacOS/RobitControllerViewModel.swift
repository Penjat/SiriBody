import Foundation
import Combine

class RobitControllerViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()
    var centralService = CentralService(serviceID: TransferService.robitComandsServiceUUID, charID: TransferService.robitCommnadsCharacteristicUUID)
    @Published var recievedData = [String]()
    @Published var messageText = ""
    init() {
        centralService.data.receive(on: DispatchQueue.main, options: nil).sink { text in
            print("\(text)")
            self.recievedData.append(text)
        }.store(in: &bag)
        
        centralService.centralState.sink { state in
            switch state {
                
            case .unknown:
                print("Unknown")
            case .resetting:
                print("restting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("Powered off")
            case .poweredOn:
                print("Powered on")
                self.centralService.retrievePeripheral()
            @unknown default:
                print("Unknown")
            }
        }.store(in: &bag)
    }
}
