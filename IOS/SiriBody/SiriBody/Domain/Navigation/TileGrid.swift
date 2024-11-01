import Foundation
import Combine


struct GridPosition: Equatable, Hashable {
    let x: Int
    let z: Int
}

protocol TileGrid {
    func findPossibleNeighbors(forTile tile: GridPosition) -> [GridPosition]
    func tile(_ position: GridPosition) -> UInt8?
}
