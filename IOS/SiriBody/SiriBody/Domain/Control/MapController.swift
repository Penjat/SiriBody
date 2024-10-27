import Foundation
import Combine


struct GridPosition: Equatable {
    let x: Int
    let z: Int
}

class MapController: ObservableObject {

    static let gridSize = 100
    static var hlafGridSize: Int {
        MapController.gridSize/2
    }

    enum MapEvent {
        case updateTiles([(value: Int, position: GridPosition)])
    }

    let events = PassthroughSubject<MapEvent, Never>()
    @Published var robitGridPosition: GridPosition?
    @Published var grid: [[UInt8]] = Array(
        repeating: Array(repeating: UInt8(0), count: gridSize),
        count: gridSize
    )

    init() {
        grid[2][3] = 2

        grid[10][10] = 1

        grid[4][2] = 3
    }

    func setTile(value: Int, x: Int, z: Int) {
        let gridPointX = x+MapController.hlafGridSize
        let gridPointZ = z+MapController.hlafGridSize

        guard
            gridPointX > 0,
            gridPointX < MapController.gridSize,
            gridPointZ > 0,
            gridPointZ < MapController.gridSize else {
            return
        }

        events
            .send(.updateTiles([(value: value, position: GridPosition(x: gridPointX, z: gridPointZ))]))
    }
}
