import Foundation
import CoreBluetooth
import Combine

class GloveDataService: ObservableObject {
    var centralService = CentralService(serviceID: TransferService.powerGloveServiceUUID, charID: TransferService.powerGloveCharacteristicUUID)
    @Published var gloveState: PowerGloveDataObject?
    var bag = Set<AnyCancellable>()

    init() {
        centralService.data
            .receive(on: DispatchQueue.main, options: nil)
            .compactMap{ PowerGloveDataObject.initWithData(data: $0) }
            .sink{ [weak self] data in
                self?.gloveState = data
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
