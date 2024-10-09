import Foundation

func approximatelyEqual(_ a: Double, _ b: Double, tolerance: Double = 0.01) -> Bool {
    return abs(a - b) < tolerance
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
