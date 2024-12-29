import Foundation

enum TransferCode: UInt8 {
    
    // Commands
    case turnTo = 1
    case moveTo = 2
    
    // Settings
    case setRotationP = 4
    case setRotationI = 5
    case setRotationD = 6
    case setRotationMax = 7
    
    case setTranslationP = 8
    case setTranslationI = 9
    case setTranslationD = 10
    case setTranslationMax = 11
    
    case unknown = 0
}

enum Command: Equatable {
    // TODO: rename TransferCode
    
    case turnTo(angle: Double)
    case moveTo(x: Double, z: Double)
    static func createFrom(data: Data) -> Command? {
        switch TransferCode.init(rawValue: data[0]) {
        case .turnTo:
            let angle = TransferService.rotationFrom(data: Data([data[1], data[2]])) ?? 0.0
            return .turnTo(angle: angle)
        case .moveTo:
            let (x, z) = TransferService.dataToFloats(data.dropFirst(1)) ?? (8, 8)
            return .moveTo(x: Double(x), z: Double(z))
        default:
            return nil
        }
    }

    func toData() -> Data {
        switch self {
        case .turnTo(angle: let angle):
            return Data([TransferCode.turnTo.rawValue]) + TransferService.rotationToData(value: angle)
        case .moveTo(x: let x, z: let z):
            return Data([TransferCode.moveTo.rawValue]) + TransferService.floatsToData(x, z)
        }
    }
}
