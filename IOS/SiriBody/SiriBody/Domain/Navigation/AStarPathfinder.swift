import Foundation
import Combine

class AStarPathfinder: ObservableObject {
    // Given a grid
    // and start and end points
    // Navigate find the optimal path between the tow points
    //or return that the path is blocked
    // How does ASart work again? 😅


    // How would I ideally like it to work?
    // Pass in a grid
    // async use algorithm to find path
    // returns an array of points
    // or noPathFound
    // will have to add more cases 

    enum Result {
        case foundPath([GridPosition])
        case noPathFound
        // TODO: cases for unkown or blocked
    }

    func findPath(start: GridPosition, goal: GridPosition, grid: [[UInt8]]) -> AStarPathfinder.Result {
        //TODO: make this work
        return .noPathFound
    }
}
