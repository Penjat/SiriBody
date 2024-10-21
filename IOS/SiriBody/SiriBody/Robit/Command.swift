import Foundation



enum Command {
    enum CommandCode: UInt8 {
        case turnTo = 1
        case moveTo = 2
        case unknown = 0
    }

    case turnTo(angle: Double)
    case moveTo(x: Double, z: Double)
    static func createFrom(data: Data) -> Command? {
        switch CommandCode.init(rawValue: data[0]) {
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
            return Data([CommandCode.turnTo.rawValue]) + TransferService.rotationToData(value: angle)
        case .moveTo(x: let x, z: let z):
            return Data([CommandCode.moveTo.rawValue]) + TransferService.floatsToData(x, z)
        }
    }
}
