import Foundation
import Combine


struct GridPosition: Equatable, Hashable {
    let x: Int
    let z: Int
}

struct SquareGrid {
    var grid: [[UInt8]]

    init(size: Int = 100) {
        grid = Array(
           repeating: Array(repeating: UInt8(0), count: size),
           count: size)
    }

    var size: Int {
        grid.count
    }

    var halfSize: Int {
        grid.count/2
    }

    func tile(_ position: GridPosition) -> UInt8? {
        guard position.x > 0, position.z > 0, position.x < size, position.z < size else {
            return nil
        }
        return grid[position.x][position.z]
    }
}

class RobitMap: ObservableObject {

    enum MapEvent {
        case updateTiles([(value: UInt8, position: GridPosition)])
    }

    let events = PassthroughSubject<MapEvent, Never>()
    @Published var robitGridPosition: GridPosition?
    @Published var grid = SquareGrid()

    init() {
        
    }

    func setTile(value: UInt8, x: Int, z: Int) {
        let gridPointX = x+grid.halfSize
        let gridPointZ = z+grid.halfSize

        guard
            gridPointX > 0,
            gridPointX < grid.grid.count,
            gridPointZ > 0,
            gridPointZ < grid.grid.count else {
            return
        }
        grid.grid[gridPointX][gridPointZ] = value

        events
            .send(.updateTiles([(value: value, position: GridPosition(x: gridPointX, z: gridPointZ))]))
    }
}
