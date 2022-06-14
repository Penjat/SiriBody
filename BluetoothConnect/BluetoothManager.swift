import Combine
import CoreBluetooth

final class BluetoothManager: NSObject, CBPeripheralDelegate {
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    private var centralManager: CBCentralManager!
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var connectedBody: CBPeripheral?
    
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
        stateSubject.send(central.state)
        eventSubject.send(.DidUpdateState(state: central.state))
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
        eventSubject.send(.DidDiscover(central: central, peripheral: peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        connectedBody = peripheral
        connectedBody?.discoverServices(nil)
        eventSubject.send(.DidConnect(central: central, peripheral: peripheral))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
        eventSubject.send(.DidDiscoverService(peripheral: peripheral, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics.")
        eventSubject.send(.DidDiscoverCharacteristic(peripheral: peripheral, service: service, error: error))
        for characteristic in characteristics {
            print("\(characteristic)")
            txCharacteristic = characteristic
            print("TX Characteristic: \(txCharacteristic.uuid)")
        }
    }
    
    func sendData(_ data: Data) {
        if let bluefruitPeripheral = connectedBody {
            if let txCharacteristic = txCharacteristic {
                bluefruitPeripheral.writeValue(data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
}
