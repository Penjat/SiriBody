import Foundation

func approximatelyEqual(_ a: Double, _ b: Double, tolerance: Double = 0.01) -> Bool {
    return abs(a - b) < tolerance
}


