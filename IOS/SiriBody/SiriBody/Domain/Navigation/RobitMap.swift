import Foundation
import Combine


struct GridPosition: Equatable, Hashable {
    let x: Int
    let z: Int
}

class RobitMap: ObservableObject {

    static let gridSize = 100
    static var hlafGridSize: Int {
        RobitMap.gridSize/2
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
        
    }

    func setTile(value: Int, x: Int, z: Int) {
        let gridPointX = x+RobitMap.hlafGridSize
        let gridPointZ = z+RobitMap.hlafGridSize

        guard
            gridPointX > 0,
            gridPointX < RobitMap.gridSize,
            gridPointZ > 0,
            gridPointZ < RobitMap.gridSize else {
            return
        }

        events
            .send(.updateTiles([(value: value, position: GridPosition(x: gridPointX, z: gridPointZ))]))
    }
}
