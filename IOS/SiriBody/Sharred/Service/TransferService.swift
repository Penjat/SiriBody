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
