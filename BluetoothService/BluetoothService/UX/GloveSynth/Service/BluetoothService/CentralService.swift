import CoreBluetooth
import Combine

class CentralService: NSObject {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
     
    let centralState = CurrentValueSubject<CBManagerState, Never>(.unknown)
    let data = PassthroughSubject<Data, Never>()
    let commandSubject = PassthroughSubject<Data, Never>()
    
    var serviceUUID: CBUUID!
    var charUUID: CBUUID!
    
    var bag = Set<AnyCancellable>()
    
    
    init(serviceID: CBUUID, charID: CBUUID) {
        super.init()
        print("creating...")
        self.serviceUUID = serviceID
        self.charUUID = charID
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        commandSubject.sink { cmdData in
            if let transferCharacteristic = self.transferCharacteristic {
                print("sending data")
                self.discoveredPeripheral?.writeValue(cmdData, for: transferCharacteristic, type: .withoutResponse)
            }
        }.store(in: &bag)
    }
}

extension CentralService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralState.send(centralManager.state)
    }
    
    func retrievePeripheral() {
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID]))
        
        if let connectedPeripheral = connectedPeripherals.last {
            self.discoveredPeripheral = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            print("scaning")
            centralManager.scanForPeripherals(withServices: [serviceUUID],
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
        peripheral.discoverServices([serviceUUID])
        print("connected")
    }
}

extension CentralService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == serviceUUID {
            peripheral.discoverServices([serviceUUID])
        }
        //        print("connected")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
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
            print("Error receiving data: \(error.localizedDescription)")
            return

        }


        guard let characteristicData = characteristic.value else {
            print("No data received")
            return

        } // Check for minimum length including start and end markers

        data.send(characteristicData)
        guard characteristicData.count >= 12 else {
            print("Received data is too short")
            return

        } // Check for start and end markers
        guard characteristicData.first == 0x02 && characteristicData.last == 0x03 else {
            print("Invalid start or end marker")
            return

        } // Extract and process the data between the markers
        let fingerSensor1 = characteristicData[1]
        let fingerSensor2 = characteristicData[2]
        let fingerSensor3 = characteristicData[3]
        let buttonsByte = characteristicData[4]
        let button1State = (buttonsByte & (1 << 2)) != 0
        let button2State = (buttonsByte & (1 << 1)) != 0
        let button3State = (buttonsByte & 1) != 0
        let gyroX = characteristicData[5]
        let gyroY = characteristicData[6]
        let gyroZ = characteristicData[7]
        let accelX = characteristicData[8]
        let accelY = characteristicData[9]
        let accelZ = characteristicData[10] // Now you can use the extracted values as needed
        print("Finger Sensor 1: \(fingerSensor1)")
        print("Finger Sensor 2: \(fingerSensor2)")
        print("Finger Sensor 3: \(fingerSensor3)")
        print("Button 1 State: \(button1State)")
        print("Button 2 State: \(button2State)")
        print("Button 3 State: \(button3State)")
        print("Gyro X: \(gyroX), Y: \(gyroY), Z: \(gyroZ)")
        print("Accel X: \(accelX), Y: \(accelY), Z: \(accelZ)")

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
        guard characteristic.uuid == TransferService.powerGloveCharacteristicUUID else { return }
        
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
