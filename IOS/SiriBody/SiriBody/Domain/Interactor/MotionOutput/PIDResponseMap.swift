import Foundation

struct DataPoint: Codable {
    let x: Double
    let y: Double
}

struct PIDResponseMap: Codable {
    static let recordDuration = 5.0
    let targetValue: Double
    let dataPoints: [DataPoint]
    
    func plus(_ point: DataPoint) -> PIDResponseMap {
        return PIDResponseMap(targetValue: targetValue, dataPoints: dataPoints + [point])
    }
    
    func saveToJSONFile(at url: URL) throws {
            let encoder = JSONEncoder()
            // If you want pretty-printed JSON, enable this:
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(self)
            try data.write(to: url)
        }
}
