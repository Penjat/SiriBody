import Foundation
import CoreBluetooth
import Combine

class PeripheralService: NSObject {
    var peripheralManager: CBPeripheralManager!
    
    let peripheralState = PassthroughSubject<CBManagerState, Never>()
    let dataOUT = PassthroughSubject<Data, Never>()
    let dataIN = PassthroughSubject<Command, Never>()
    
    var transferCharacteristic: CBMutableCharacteristic?
    
    var bag = Set<AnyCancellable>()
    
    func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        dataOUT.sink { data in
            if let transferCharacteristic = self.transferCharacteristic {
                self.peripheralManager.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil)
            }
        }.store(in: &bag)
    }
}

extension PeripheralService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        peripheralState.send(peripheral.state)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("was subscribed to")
    }
    
    
    func setupPeripheral() {
        let transferCharacteristic = CBMutableCharacteristic(type: TransferService.characteristicUUID,
                                                             properties: [.notify, .writeWithoutResponse],
                                                             value: nil,
                                                             permissions: [.readable, .writeable])
        
        let transferService = CBMutableService(type: TransferService.serviceUUID, primary: true)
        transferService.characteristics = [transferCharacteristic]
        
        peripheralManager.add(transferService)
        self.transferCharacteristic = transferCharacteristic
    }
    
    func startAdvertising() {
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TransferService.serviceUUID]])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                  let stringFromData = Command(rawValue: ([UInt8](requestValue)).first ?? 0) else {
                      continue
                  }
            dataIN.send(stringFromData)
        }
    }
}
