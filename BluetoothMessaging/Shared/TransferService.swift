import Foundation
import CoreBluetooth

class TransferService {
    static let robitComandsServiceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    static let robitCommnadsCharacteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")
    static let siriBodyServiceUUID = CBUUID(string: "FFE0")
    static let siriBodyCharUUID = CBUUID(string: "FFE1")
}

enum Command: UInt8 {
    case faceNorth = 1
    case faceSouth = 2
    case faceWest = 3
    case faceEast = 4
    case moveForward = 5
    case unknown = 6
    
    case justLeft = 7
    case justRight = 8
    case speed10 = 9
    case speed20 = 10
    case speed30 = 11
    case speed40 = 12
    case speed50 = 13
    case speed60 = 14
    case speed70 = 15
    case speed80 = 16
    case speed90 = 17
    case speed100 = 18
    
    
    
    func data() -> Data {
        return Data([self.rawValue])
    }
    
    func GetCommand(from data: Data) -> Command {
        let array = [UInt8](data)
        return Command(rawValue: array.first ?? 0) ?? .unknown
    }
}

enum RobitCommand {
    case turnLeft
    case stop
}


