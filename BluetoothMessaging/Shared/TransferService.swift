import Foundation
import CoreBluetooth

class TransferService {
    static let robitComandsServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let robitCommnadsCharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    static let siriBodyServiceUUID = CBUUID(string: "FFE0")
    static let siriBodyCharUUID = CBUUID(string: "FFE1")
}

enum Command: UInt8 {
    case turn360 = 3
    case unknown = 0
    
    func data() -> Data {
        return Data([self.rawValue])
    }
    
    func GetCommand(from data: Data) -> Command {
        let array = [UInt8](data)
        return Command(rawValue: array.first ?? 0) ?? .unknown
    }
}
