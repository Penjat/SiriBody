import Foundation

enum CommandCode: UInt8 {
    case turnTo = 1
    case unknown = 0
}

enum Command {
    case turnTo(angle: Double)
    case unknown
    
    func createFrom(data: Data) -> Command {
        switch CommandCode.init(rawValue: data[0]) {
        case .turnTo:
            return .turnTo(angle: 23 )
        default:
            return .unknown
        }
    }
}
