import Foundation
import Combine


class RobitMap: ObservableObject {
    
    // how many tiles per cm
    static let gridResolution: Float = 4.0

    enum MapEvent {
        case updateTiles([(value: UInt8, position: GridPosition)])
    }

    let events = PassthroughSubject<MapEvent, Never>()
    @Published var robitGridPosition: GridPosition?
    @Published var grid = SquareGrid()

    init(statePublisher: some Publisher<RobitState, Never>) {
        statePublisher
            .map { GridPosition(
                x: Int($0.position.x/RobitMap.gridResolution),
                z: Int($0.position.z/RobitMap.gridResolution))  }
            .removeDuplicates()
            .assign(to: &$robitGridPosition)
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
        for x in -grid.halfSize..<grid.halfSize {
            for z in -grid.halfSize..<grid.halfSize {
                setTile(value: 0, x: x, z: z)
            }
        }

    }
}
