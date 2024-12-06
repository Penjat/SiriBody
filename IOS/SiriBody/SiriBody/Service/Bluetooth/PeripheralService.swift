import Foundation
import Combine
import CoreBluetooth


class PeripheralService: NSObject {
    enum ConnectionState {
        case advertising
        case connected(CBCentral)
        case disconnected
    }
    var peripheralManager: CBPeripheralManager?
    var serviceUUID: CBUUID!
    var charUUID: CBUUID!
    var bag = Set<AnyCancellable>()
    
    let inputSubject = PassthroughSubject<Data, Never>()
    let outputSubject = PassthroughSubject<Data, Never>()
    let connectionStateSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)

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

                let success = self?.peripheralManager?.updateValue(data, for: transferCharacteristic, onSubscribedCentrals: nil) ?? false
                
                if success {
//                    print("Data sent successfully")
                } else {
                    print("Failed to send data")
                }
                
            }.store(in: &bag)
    }
}

extension PeripheralService: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startAdvertising()

        }
    }
    
    func startAdvertising() {
        transferCharacteristic = CBMutableCharacteristic(
            type: charUUID,
            properties: [.writeWithoutResponse, .read, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [transferCharacteristic!]

        peripheralManager?.add(service)

        peripheralManager?.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
        ])
        connectionStateSubject.send(.advertising)
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
        peripheralManager?.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        connectionStateSubject.send(.connected(central))
        print("Peripheral was connected to")
    }
}
