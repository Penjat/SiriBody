import Foundation
import Combine


struct GridPosition: Equatable {
    let x: Int
    let z: Int
}

class MapController: ObservableObject {
    
    @Published var robitGridPosition: GridPosition?
    @Published var grid: [[UInt8]] = Array(
        repeating: Array(repeating: UInt8(0), count: 100),
        count: 100
    )

    init() {
        grid[2][3] = 2

        grid[10][10] = 1

        grid[4][2] = 3
    }
}
