import Foundation
import Combine


class AStarPathfinder {

    struct TileScroe {
        let position: GridPosition
        let previousTile: GridPosition?
        let gScore: Int
        let wScore: Int
        var score: Int {
            gScore + wScore
        }
    }

    enum PathError: Error {
        case noPathFound
    }

    enum Event {
        case findingPath(posibleTiles: [GridPosition: TileScroe], visitedTiles: [GridPosition: TileScroe])
        case foundPath([GridPosition])
        // TODO: cases for unkown or blocked
    }

    static func findPath(startingTile: GridPosition, goal: GridPosition, grid: TileGrid) -> any Publisher<AStarPathfinder.Event, PathError> {

        let subject = PassthroughSubject<AStarPathfinder.Event, PathError>()

        DispatchQueue.main.async {

            var posibleTiles = [GridPosition: TileScroe]()
            var previousScore = TileScroe(position: startingTile, previousTile: nil, gScore: distanceFromGoal(tile: startingTile, goal: goal), wScore: 0)

            var visitedTiles = [startingTile: previousScore]
            var running = true
            while running {

                grid.findPossibleNeighbors(forTile: previousScore.position)
                    .filter { visitedTiles[$0] == nil && posibleTiles[$0] == nil }
                    .forEach { tile in
                        let distanceToGoal = distanceFromGoal(tile: tile, goal: goal)
                        posibleTiles[tile] = TileScroe(position: tile, previousTile: previousScore.position, gScore: distanceToGoal, wScore: previousScore.wScore+1)
                    }
                
                print(posibleTiles.map{ ($0.value.position, $0.value.gScore)})
                subject.send(Event.findingPath(posibleTiles: posibleTiles, visitedTiles: visitedTiles))

                let nextTile = posibleTiles
                    .sorted { $0.value.score < $1.value.score }
                    .first?.value

                guard let nextTile else {
                    subject.send(completion: .failure(PathError.noPathFound))
                    running = false
                    return
                }

                posibleTiles.removeValue(forKey: nextTile.position)
                visitedTiles[nextTile.position] = nextTile

                if nextTile.position == goal {
                    let pathBack = findWayBack(nextTile.position, tiles: visitedTiles)
                    let optimizedPath = AStarPathfinder.optimize(path: pathBack, grid: grid)
                    subject.send(Event.foundPath(optimizedPath))
                    subject.send(completion: .finished)
                    running = false
                    return
                }

                print(nextTile.position)
                previousScore = nextTile

            }
        }
        return subject.eraseToAnyPublisher()
    }

    static func distanceFromGoal(tile: GridPosition, goal: GridPosition) -> Int {
        return  abs(goal.x-tile.x) + abs(goal.z - tile.z)
//        let xDistance = Double(abs(goal.x - tile.x))
//        let zDistance = Double(abs(goal.z - tile.z))
//
//        return Int(sqrt(xDistance*xDistance + zDistance*zDistance))
    }

    static func findWayBack(_ tile: GridPosition, tiles: [GridPosition: TileScroe]) -> [GridPosition] {
        
        var output = [tile]
        while true {
            guard let index = output.last, let nextTile = tiles[index]?.previousTile else {
                return output
            }
            output.append(nextTile)
        }
    }

    static func pathClear(p1: GridPosition, p2: GridPosition, grid: TileGrid) -> Bool {
        // check all points in between and see if blocked
        let distanceX = abs(p2.x - p1.x)
        let distanceZ = abs(p2.z - p1.z)

        if distanceX > distanceZ {
            let direction = (p1.x < p2.x) ? 1 : -1
            let slope = distanceZ != 0 ? Double(p2.x - p1.x) / Double(p2.z - p1.z) : 0.0
            for i in 0..<distanceX {
                if let value = grid.tile(GridPosition(x: p1.x + direction*i, z: p1.z + Int(Double(i)*slope))), value > 2 {
                    return false
                }
            }
        } else {
            let direction = (p1.z < p2.z) ? 1 : -1
            let slope = distanceX != 0 ? Double(p2.z - p1.z) / Double(p2.x - p1.x) : 0.0
            for i in 0..<distanceZ {
                if let value = grid.tile(GridPosition(x: p1.x + Int(Double(i)*slope), z: p1.z + direction*i)), value > 2 {
                    return false
                }
            }
        }
        return true
    }

    static func optimize(path: [GridPosition], grid: TileGrid) -> [GridPosition] {
        guard let firstNode = path.first, let lastNode = path.last else {
            return path
        }

        return path
            .dropFirst()
            .reduce((firstNode, [firstNode])) { partialResult, position in

                // check if pathClear between
                if AStarPathfinder.pathClear(p1: partialResult.1.last!, p2: position, grid: grid) {

                    return (position, partialResult.1)
                } else {
                    return (position, partialResult.1 + [partialResult.0])
                }
        }.1 + [lastNode]
    }
}
