import Foundation
import Combine

class BluetoothInteractor: ObservableObject {
    let centralService: CentralService
    let peripheralService: PeripheralService?

    init(centralService: CentralService, peripheralService: PeripheralService? = nil) {
        self.centralService = centralService
        self.peripheralService = peripheralService
    }
}
