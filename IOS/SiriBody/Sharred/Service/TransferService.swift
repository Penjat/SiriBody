import Foundation
import CoreBluetooth

class TransferService {
    static let siriBodyServiceUUID = CBUUID(string: "FFE0")
    static let siriBodyCharUUID = CBUUID(string: "FFE1")
    static let startingCharacter: UInt8 = 0x02
    static let endingCharacter: UInt8 = 0x03
    
    static let phoneServiceUUID = CBUUID(string: "FFE5")
    static let phoneCharUUID = CBUUID(string: "FFE6")
}

enum CommandCode: UInt8 {
    case turnTo = 1
    case unknown = 0
}

enum Command {
    case turnTo(angle: Double)
    
    
    static func createFrom(data: Data) -> Command? {
        switch CommandCode.init(rawValue: data[0]) {
        case .turnTo:
            let angle = rotationFrom(data: Data([data[1], data[2]])) ?? 0.0
            return .turnTo(angle: angle)
        default:
            return nil
        }
    }
    
    func toData() -> Data {
        switch self {
        case .turnTo(angle: let angle):
            return Data([CommandCode.turnTo.rawValue]) + rotationToData(value: angle)
        }
    }
}
