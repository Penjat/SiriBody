import Foundation
import CoreBluetooth

class TransferService {
//    static let robitComandsServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
//    static let robitCommnadsCharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    static let siriBodyServiceUUID = CBUUID(string: "FFE0")
    static let siriBodyCharUUID = CBUUID(string: "FFE1")

    static let powerGloveServiceUUID  = CBUUID(string: "FFE0")
    static let powerGloveCharacteristicUUID  = CBUUID(string: "FFE1")
}

enum BTMessage: UInt8 {
    case unknown = 0
    
    
    func data() -> Data {
        return Data([self.rawValue])
    }
    
    func GetCommand(from data: Data) -> BTMessage {
        let array = [UInt8](data)
        return BTMessage(rawValue: array.first ?? 0) ?? .unknown
    }
}
