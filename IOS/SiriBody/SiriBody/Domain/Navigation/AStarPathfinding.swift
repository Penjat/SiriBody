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

    static func findPath(startingTile: GridPosition, goal: GridPosition, grid: SquareGrid) -> any Publisher<AStarPathfinder.Event, PathError> {

        let subject = PassthroughSubject<AStarPathfinder.Event, PathError>()

        DispatchQueue.main.async {

            var posibleTiles = [GridPosition: TileScroe]()
            var previousScore = TileScroe(position: startingTile, previousTile: nil, gScore: distanceFromGoal(tile: startingTile, goal: goal), wScore: 0)

            var visitedTiles = [startingTile: previousScore]
            var running = true
            while running {

                findPossibleNeighbors(forTile: previousScore.position, grid: grid)
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
                    subject.send(Event.foundPath(pathBack))
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

    static func findPossibleNeighbors(forTile tile: GridPosition, grid: SquareGrid) -> [GridPosition] {

        var output = [GridPosition]()
        for x in -1...1 {
            for z in -1...1 {
                let xPos = tile.x + x
                let zPos = tile.z + z
                if let neightbor = grid.tile(GridPosition(x: xPos, z: zPos)), neightbor < 2 {
                    output.append(GridPosition(x: xPos, z: zPos))
                }
            }
        }

        return output
    }

    static func distanceFromGoal(tile: GridPosition, goal: GridPosition) -> Int{
        return  abs(goal.x-tile.x) + abs(goal.z - tile.z)
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
}
