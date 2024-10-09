import CoreBluetooth
import Combine

enum ConnectionState {
    case scanning
    case connected(CBPeripheral)
    case disconnected
}

class CentralService: NSObject, ObservableObject {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
     
    let centralState = PassthroughSubject<CBManagerState, Never>()
    let data = PassthroughSubject<String, Never>()
    let outputSubject = PassthroughSubject<Data, Never>()
    
    @Published var connectionState = ConnectionState.disconnected
    
    var serviceUUID: CBUUID!
    var charUUID: CBUUID!
    
    var bag = Set<AnyCancellable>()
    
    init(serviceID: CBUUID, charID: CBUUID) {
        super.init()
        print("creating...")
        self.serviceUUID = serviceID
        self.charUUID = charID
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        outputSubject
            .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true)
            .sink { cmdData in
                print(cmdData[1])
            if let transferCharacteristic = self.transferCharacteristic {
                
                self.discoveredPeripheral?.writeValue(cmdData, for: transferCharacteristic, type: .withoutResponse)
            }
        }.store(in: &bag)
    }
}

extension CentralService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralState.send(centralManager.state)
    }
    
    func stopScanning() {
        centralManager.stopScan()
        connectionState = .disconnected
    }
    
    func retrievePeripheral() {
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID]))
        
        if let connectedPeripheral = connectedPeripherals.last {
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            print("scaning...")
            connectionState = .scanning
            centralManager.scanForPeripherals(withServices: [serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
            discoveredPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        print("discovered \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        connectionState = .connected(peripheral)
        print("connected")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        connectionState = .disconnected
    }
}

extension CentralService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == serviceUUID {
            peripheral.discoverServices([serviceUUID])
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
            print("discovered service: \(service)")
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == charUUID {
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            print("discovered characteristic: \(characteristic)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        data.send(stringFromData)
        print("recieved: \(stringFromData)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        
        if characteristic.isNotifying {
           
            
        } else {

        }
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {

    }
    
}
