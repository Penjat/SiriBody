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

    static func findPath(startingTile: GridPosition, goal: GridPosition, grid: [[UInt8]]) -> any Publisher<AStarPathfinder.Event, PathError> {

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

                subject.send(Event.findingPath(posibleTiles: posibleTiles, visitedTiles: visitedTiles))

                let nextTile = posibleTiles
                    .sorted { $0.value.score < $1.value.score }
                    .first?.value

                if nextTile?.position == goal {
                    subject.send(Event.foundPath([]))
                    subject.send(completion: .finished)
                }

                guard let nextTile else {
                    subject.send(completion: .failure(PathError.noPathFound))
                    running = false
                    return
                }

                posibleTiles.removeValue(forKey: nextTile.position)
                previousScore = nextTile

            }
        }
        return subject.eraseToAnyPublisher()
    }

    static func findPossibleNeighbors(forTile tile: GridPosition, grid:[[UInt8]]) -> [GridPosition] {

        return []
    }

    static func distanceFromGoal(tile: GridPosition, goal: GridPosition) -> Int{
        return max(abs(goal.x-tile.x), abs(goal.z - tile.z))
    }

    static func findWayBack(_ tile: GridPosition) -> [GridPosition] {

        return []
    }
}
