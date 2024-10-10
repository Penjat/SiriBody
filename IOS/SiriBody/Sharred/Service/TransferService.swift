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

func rotationToData(value: Double) -> Data {
    // Ensure the value is within the specified range
    let clampedValue = min(max(value, -Double.pi), Double.pi)
    
    // Scale the value and convert to Int16 (precision to two decimal places)
    let scaledValue = Int16(clampedValue * 100)  // 100 for 2 decimal places
    
    // Convert Int16 to Data
    var data = Data()
    data.append(contentsOf: withUnsafeBytes(of: scaledValue.bigEndian) { Array($0) })
    
    return data
}

func rotationFrom(data: Data) -> Double? {
    guard data.count == 2 else { return nil } // Int16 is 2 bytes
    let scaledValue = data.withUnsafeBytes { $0.load(as: Int16.self).bigEndian }
    return Double(scaledValue) / 100.0
}
