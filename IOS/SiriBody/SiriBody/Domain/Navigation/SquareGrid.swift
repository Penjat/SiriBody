import Foundation
import Combine

struct SquareGrid: TileGrid {
    
    var grid: [[UInt8]]

    init(size: Int = 100) {

        let array = Array(
            repeating: Array(repeating: UInt8(0), count: size*2),
            count: size*2)
        grid = array
    }

    var size: Int {
        grid.count
    }

    var halfSize: Int {
        grid.count/2
    }

    func tile(_ position: GridPosition) -> UInt8? {
        guard position.x > -halfSize, position.z > -halfSize, position.x < halfSize, position.z < size else {
            return nil
        }
        return grid[position.x+halfSize][position.z+halfSize]
    }

    func findPossibleNeighbors(forTile tile: GridPosition) -> [GridPosition] {

        var output = [GridPosition]()
        for x in -1...1 {
            for z in -1...1 {
                let xPos = tile.x + x
                let zPos = tile.z + z
                if let neightbor = self.tile(GridPosition(x: xPos, z: zPos)), neightbor < 3 {
                    output.append(GridPosition(x: xPos, z: zPos))
                }
            }
        }

        return output
    }
}
