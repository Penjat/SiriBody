import Foundation
import CoreBluetooth

class TransferService {
    static let siriBodyServiceUUID = CBUUID(string: "FFE0")
    static let siriBodyCharUUID = CBUUID(string: "FFE1")
    static let startingCharacter: UInt8 = 0x02
    static let endingCharacter: UInt8 = 0x03

    static let phoneServiceUUID = CBUUID(string: "FFE5")
    static let phoneCharUUID = CBUUID(string: "FFE6")

    static func bluetoothMessageFor(motorOutput: MotorOutput) -> Data {
        let motorDirectionByte = UInt8((motorOutput.motor1 > 0 ? 1 : 0) + (motorOutput.motor2 > 0 ? 2 : 0))
        let motor1Byte = UInt8(abs(motorOutput.motor1))
        let motor2Byte = UInt8(abs(motorOutput.motor2))

        return Data(
                    [UInt8(253),
                     motorDirectionByte,
                     motor1Byte,
                     motor2Byte,
                     UInt8(252)
                    ]
        )
    }

    static func rotationToData(value: Double) -> Data {
        // Ensure the value is within the specified range
        let clampedValue = min(max(value, -Double.pi), Double.pi)

        // Scale the value and convert to Int16 (precision to two decimal places)
        let scaledValue = Int16(clampedValue * 100)  // 100 for 2 decimal places

        // Convert Int16 to Data
        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: scaledValue.bigEndian) { Array($0) })

        return data
    }

    static func rotationFrom(data: Data) -> Double? {
        guard data.count == 2 else { return nil } // Int16 is 2 bytes
        let scaledValue = data.withUnsafeBytes { $0.load(as: Int16.self).bigEndian }
        return Double(scaledValue) / 100.0
    }

    static func floatsToData(_ firstDouble: Double, _ secondDouble: Double) -> Data {
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

    static func dataToFloats(_ data: Data) -> (Float, Float)? {
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

    static func dataToSIMD3Float(_ data: Data) -> SIMD3<Float>? {
        guard data.count == MemoryLayout<SIMD3<Float>>.size else {
            return nil
        }
        return data.withUnsafeBytes { $0.load(as: SIMD3<Float>.self) }
    }
    
    
    
    static func dataToDouble(_ data: Data) -> Double? {
        guard data.count >= MemoryLayout<Double>.size else { return nil }
        
        return data.withUnsafeBytes { rawBuffer -> Double in
            var value: Double = 0
            // Copy the bytes into `value` (on the stack), which is correctly aligned
            memcpy(&value, rawBuffer.baseAddress!, MemoryLayout<Double>.size)
            return value
        }
    }

    /// Converts `Data` (containing 8 bytes) back into a `Double`.
    static func doubleToData(_ value: Double) -> Data {
        var mutableValue = value
        // Copy from our aligned stack variable into a new `Data`
        return withUnsafePointer(to: mutableValue) { ptr in
            Data(bytes: ptr, count: MemoryLayout.size(ofValue: mutableValue))
        }
    }

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
