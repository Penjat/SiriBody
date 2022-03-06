import Combine
import CoreBluetooth

final class BluetoothManager: NSObject, CBPeripheralDelegate {
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    private var centralManager: CBCentralManager!
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var connectedBody: CBPeripheral?
    
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
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    func sendMessageToDevice(_ message: String) {
        //            guard isReady else { return }
        
        //            if let data = message.data(using: String.Encoding.utf8) {
        //                connectedBody.writeValue(data, for: writeCharacteristic!, type: writeType)
        //            }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        connectedBody = peripheral
        connectedBody?.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services \(peripheral)")
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
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics.")
        
        for characteristic in characteristics {
            print("\(characteristic)")
            //            if characteristic.uuid.isEqual(CBUUID.BLE_Characteristic_uuid_Rx)  {
            //
            //                rxCharacteristic = characteristic
            //
            //                peripheral.setNotifyValue(true, for: rxCharacteristic!)
            //                peripheral.readValue(for: characteristic)
            //
            //                print("RX Characteristic: \(rxCharacteristic.uuid)")
            //            }
            //
            //            if characteristic.uuid.isEqual(CBUUID.BLE_Characteristic_uuid_Tx){
            //
            txCharacteristic = characteristic
            //
            print("TX Characteristic: \(txCharacteristic.uuid)")
            //            }
            
            
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
