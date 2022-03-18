import Foundation
import Combine

class RobitViewModel: ObservableObject {
    let peripheralService = PeripheralService()
    @Published var messageText = ""
    @Published var reciededData = [String]()
    
    var bag = Set<AnyCancellable>()
    
    init() {
        peripheralService.dataIN.receive(on: DispatchQueue.main, options: nil).sink { text in
            self.reciededData.append(text)
        }.store(in: &bag)
        
        peripheralService.peripheralState.sink { state in
            switch state {
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("powered off")
            case .poweredOn:
                print("powered on")
                self.peripheralService.setupPeripheral()
                self.peripheralService.startAdvertising()
            }
        }.store(in: &bag)
        
        peripheralService.start()
    }
}
