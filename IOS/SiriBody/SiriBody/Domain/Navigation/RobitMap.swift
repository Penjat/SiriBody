import Foundation
import Combine


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
            gridPointX < grid.size,
            gridPointZ > 0,
            gridPointZ < grid.size else {
                return
            }

        grid.grid[gridPointX][gridPointZ] = value

        events
            .send(.updateTiles([(value: value, position: GridPosition(x: gridPointX, z: gridPointZ))]))
    }

    public func clearGrid() {
        grid = SquareGrid()
    }
}
