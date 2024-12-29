import Foundation

struct PIDResponseMap {
    static let recordDuration = 5.0
    let targetValue: Double
    let dataPoints: [(Double, Double)]
    
    func plus(_ point: (Double, Double)) -> PIDResponseMap {
        return PIDResponseMap(targetValue: targetValue, dataPoints: dataPoints + [point])
    }
}
