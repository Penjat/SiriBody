import Foundation
import Combine


struct GridPosition: Equatable, Hashable {
    let x: Int
    let z: Int
}

struct SquareGrid {
    let grid: [[UInt8]]

    init(size: Int = 100) {
        grid = Array(
           repeating: Array(repeating: UInt8(0), count: size),
           count: size)
    }

    var halfSize: Int {
        grid.count/2
    }
}

class RobitMap: ObservableObject {

    enum MapEvent {
        case updateTiles([(value: Int, position: GridPosition)])
    }

    let events = PassthroughSubject<MapEvent, Never>()
    @Published var robitGridPosition: GridPosition?
    @Published var grid = SquareGrid()

    init() {
        
    }

    func setTile(value: Int, x: Int, z: Int) {
        let gridPointX = x+grid.halfSize
        let gridPointZ = z+grid.halfSize

        guard
            gridPointX > 0,
            gridPointX < grid.grid.count,
            gridPointZ > 0,
            gridPointZ < grid.grid.count else {
            return
        }

        events
            .send(.updateTiles([(value: value, position: GridPosition(x: gridPointX, z: gridPointZ))]))
    }
}
