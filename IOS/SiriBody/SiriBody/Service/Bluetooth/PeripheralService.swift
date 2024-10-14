import Foundation
import Combine
import CoreBluetooth

// Central Service and Transfer Service in Sharred Folder



class PeripheralService: NSObject, ObservableObject {
    enum ConnectionState {
        case scanning
        case connected(CBPeripheral)
        case disconnected
    }
    var peripheralManager: CBPeripheralManager?
    var serviceUUID: CBUUID!
    var charUUID: CBUUID!
    var bag = Set<AnyCancellable>()
    
    let inputSubject = PassthroughSubject<Data, Never>()
    let outputSubject = PassthroughSubject<Data, Never>()
    
    var transferCharacteristic: CBMutableCharacteristic?
    
    init(serviceID: CBUUID, charID: CBUUID) {
        super.init()
        print("creating...")
        self.serviceUUID = serviceID
        self.charUUID = charID
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        outputSubject
            .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] data in
                guard let transferCharacteristic = self?.transferCharacteristic else {
                    print("Characteristic not found")
                    return
                }
                
                // Update the characteristic value and notify subscribers
                let success = self?.peripheralManager?.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil) ?? false
                
                if success {
                    print("Data sent successfully")
                } else {
                    print("Failed to send data")
                }
                
            }.store(in: &bag)
    }
}

extension PeripheralService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            // Start advertising as a peripheral once the manager is powered on
            startAdvertising()
        }
    }
    
    func startAdvertising() {
        // Create a characteristic with properties for reading/writing
        transferCharacteristic = CBMutableCharacteristic(
            type: charUUID,
            properties: [.writeWithoutResponse, .read, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        // Create a service and add the characteristic to it
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [transferCharacteristic!]
        
        // Add the service to the peripheral manager
        peripheralManager?.add(service)
        
        // Start advertising the service
        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Error adding service: \(error)")
        } else {
            print("Service added successfully")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Error advertising: \(error)")
        } else {
            print("Started advertising as a peripheral")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value {
                inputSubject.send(value)
            }
            peripheralManager?.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // Respond to read requests here if needed
        peripheralManager?.respond(to: request, withResult: .success)
    }
}
