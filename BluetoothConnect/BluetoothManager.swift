import Combine
import CoreBluetooth

final class BluetoothManager: NSObject, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    var eventSubject: PassthroughSubject<CentralManagerEvent, Never> = .init()
    
    func start() {
        print("starting up")
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
    
    func startScanning() {
        print("scanning")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

enum CentralManagerEvent {
    case DidUpdateState(state: CBManagerState)
    case DidDiscover(central: CBCentralManager, peripheral: CBPeripheral)
    case DidConnect(central: CBCentralManager, peripheral: CBPeripheral)
    case DidDiscoverService(peripheral: CBPeripheral, error: Error?)
    case DidDiscoverCharacteristic(peripheral: CBPeripheral, service: CBService, error: Error?)
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        eventSubject.send(.DidUpdateState(state: central.state))
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        eventSubject.send(.DidDiscover(central: central, peripheral: peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        eventSubject.send(.DidConnect(central: central, peripheral: peripheral))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        eventSubject.send(.DidDiscoverService(peripheral: peripheral, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        eventSubject.send(.DidDiscoverCharacteristic(peripheral: peripheral, service: service, error: error))
    }
}
