import CoreBluetooth
import Combine

class CentralService: NSObject {
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    
    var data = PassthroughSubject<String, Never>()
    var commandSubject = PassthroughSubject<Data, Never>()
    var bag = Set<AnyCancellable>()
    
    override init() {
        print("creating...")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        commandSubject.sink { cmdData in
            if let transferCharacteristic = self.transferCharacteristic {
                self.discoveredPeripheral?.writeValue(cmdData, for: transferCharacteristic, type: .withoutResponse)
            }
        }.store(in: &bag)
    }
}

extension CentralService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch centralManager.state {
            
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
            retrievePeripheral()
        @unknown default:
            print("Unknown")
        }
    }
    
    func retrievePeripheral() {
        
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [CentralService.serviceUUID]))
        
        if let connectedPeripheral = connectedPeripherals.last {
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            print("scaning")
            centralManager.scanForPeripherals(withServices: [CentralService.serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
        print("discovered \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CentralService.serviceUUID])
        print("connected")
    }
}

extension CentralService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == CentralService.serviceUUID {
            peripheral.discoverServices([CentralService.serviceUUID])
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            return
        }
        
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([CentralService.characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            return
        }
        
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == CentralService.characteristicUUID {
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {

            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        data.send(stringFromData)
        print("recieved: \(stringFromData)")
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == CentralService.characteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            
        } else {
            // Notification has stopped, so disconnect from the peripheral
            
//            cleanup()
        }
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
//        writeData()
    }
    
}
