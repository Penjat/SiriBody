import XCTest

final class AStarTests: XCTestCase {
    func testDistanceFrom() {
        // Given
        var start = GridPosition(x: 2, z: 2)
        var goal = GridPosition(x: 4, z: 4)

        // When
        var distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 2)


        // Given
        start = GridPosition(x: 0, z: 0)
        goal = GridPosition(x: 100, z: 10)

        // When
        distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 100)


        // Given
        start = GridPosition(x: 5, z: 15)
        goal = GridPosition(x: 0, z: 0)

        // When
        distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 15)
    }

    func testFindNeighborsWithEmptyGrid() {
        // Given
        let grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 3, z: 4)

        // When
        let neighbors = AStarPathfinder.findPossibleNeighbors(forTile: startingTile, grid: grid)

        // Then
        XCTAssertEqual(neighbors.count, 9)
    }

    func testFindNeighborsWithSomeBlocked() {
        // Given
        let grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 3, z: 4)

        // When
        let neighbors = AStarPathfinder.findPossibleNeighbors(forTile: startingTile, grid: grid)

        // Then
        XCTAssertEqual(neighbors.count, 9)
    }

}
