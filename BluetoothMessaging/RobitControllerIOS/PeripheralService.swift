import Foundation
import CoreBluetooth
import Combine

class PeripheralService: NSObject {
    static let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    
    var transferCharacteristic: CBMutableCharacteristic?
    
    var peripheralManager: CBPeripheralManager!
    
    var dataIN = PassthroughSubject<String, Never>()
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }
}

extension PeripheralService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
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
            setupPeripheral()
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [PeripheralService.serviceUUID]])
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("was subscribed to")
    }
    
    
    private func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: PeripheralService.characteristicUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        
        let transferService = CBMutableService(type: PeripheralService.serviceUUID, primary: true)
        transferService.characteristics = [transferCharacteristic]
        
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("recieved write \(requests)")
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
            dataIN.send(stringFromData)
            print("\(stringFromData)")
        }
    }
}
