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

enum StateCode: UInt8 {
    case update = 1
}

enum StateData {
    case positionOrientation(
        devicePosition: SIMD3<Float>,
        deviceOrientation: SIMD3<Float>)
    
    static func createFrom(data: Data) -> StateData? {
        switch StateCode.init(rawValue: data[0]) {
        case .update:
            // Extract the devicePosition and deviceOrientation from the data
            let positionSize = MemoryLayout<SIMD3<Float>>.size
            let orientationSize = MemoryLayout<SIMD3<Float>>.size
            let expectedLength = 1 + positionSize + orientationSize // Total expected data length

            guard data.count >= expectedLength else {
                return nil // Not enough data
            }

            // Define the ranges for position and orientation data
            let positionRange = 1..<(1 + positionSize)
            let orientationRange = (1 + positionSize)..<(1 + positionSize + orientationSize)

            // Extract the subdata for position and orientation
            let positionData = data.subdata(in: positionRange)
            let orientationData = data.subdata(in: orientationRange)

            // Reconstruct the SIMD3<Float> values
            let devicePosition = positionData.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }
            let deviceOrientation = orientationData.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }

            // Return the StateData with the extracted values
            return .positionOrientation(devicePosition: devicePosition, deviceOrientation: deviceOrientation)
        default:
            return nil
        }
    }
    
    func toData() -> Data {
        switch self {
        case .positionOrientation(devicePosition: let position, deviceOrientation: let orientation):
            let positionData = withUnsafeBytes(of: position) { Data($0) }
            let orientationData = withUnsafeBytes(of: orientation) { Data($0) }
            return Data([StateCode.update.rawValue]) + positionData + orientationData
        }
    }
}

enum CommandCode: UInt8 {
    case turnTo = 1
    case moveTo = 2
    case unknown = 0
}

enum Command {
    case turnTo(angle: Double)
    case moveTo(x: Double, z: Double)
    static func createFrom(data: Data) -> Command? {
        switch CommandCode.init(rawValue: data[0]) {
        case .turnTo:
            let angle = rotationFrom(data: Data([data[1], data[2]])) ?? 0.0
            return .turnTo(angle: angle)
        case .moveTo:
            let (x, z) = dataToFloats(data.dropFirst(1)) ?? (8, 8)
            return .moveTo(x: Double(x), z: Double(z))
        default:
            return nil
        }
    }
    
    func toData() -> Data {
        switch self {
        case .turnTo(angle: let angle):
            return Data([CommandCode.turnTo.rawValue]) + rotationToData(value: angle)
        case .moveTo(x: let x, z: let z):
            return Data([CommandCode.moveTo.rawValue]) + floatsToData(x, z)
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

func floatsToData(_ firstDouble: Double, _ secondDouble: Double) -> Data {
    var first = Float(firstDouble)
    var second = Float(secondDouble)
    var data = Data()
    
    withUnsafeBytes(of: &first) { bytes in
        data.append(contentsOf: bytes)
    }
    withUnsafeBytes(of: &second) { bytes in
        data.append(contentsOf: bytes)
    }
    return data
}

func dataToFloats(_ data: Data) -> (Float, Float)? {
    let floatSize = MemoryLayout<Float>.size
    guard data.count >= floatSize * 2 else {
        return nil // Data size mismatch
    }

    return data.withUnsafeBytes { rawBufferPointer -> (Float, Float)? in
        guard let baseAddress = rawBufferPointer.baseAddress else {
            return nil
        }

        let floatBufferPointer = baseAddress.assumingMemoryBound(to: Float.self)
        let buffer = UnsafeBufferPointer(start: floatBufferPointer, count: 2)
        let firstFloat = buffer[0]
        let secondFloat = buffer[1]
        return (firstFloat, secondFloat)
    }
}

                             func dataToSIMD3Float(_ data: Data) -> SIMD3<Float>? {
                guard data.count == MemoryLayout<SIMD3<Float>>.size else {
                    return nil
                }
                return data.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }
            }
                             
