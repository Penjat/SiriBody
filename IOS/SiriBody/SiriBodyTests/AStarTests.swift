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
        let neighbors = grid.findPossibleNeighbors(forTile: startingTile)

        // Then
        XCTAssertEqual(neighbors.count, 9)
    }

    func testFindNeighborsWithSomeBlocked() {

        // Given
        var grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 4, z: 4)
        grid.grid[3][3] = 3
        grid.grid[3][4] = 3
        grid.grid[3][5] = 3

        // When
        let neighbors = grid.findPossibleNeighbors(forTile: startingTile)

        // Then
        XCTAssertEqual(neighbors.count, 6)
    }

    func testFindPathStraightLineOnEmptyGrid() {
        // Given
        let expectation = self.expectation(description: "AStar finds path")

        let grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 4)


        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: grid).sink { completion in
            switch completion {
                case .finished:
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail()
                }
        } receiveValue: { value in
            switch value {
            case .foundPath(let path):
                
                XCTAssertEqual(path.count, 3)
            default:
                break
            }
        }

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
    }


    func testFindPathDiagonalLineOnEmptyGrid() {
        // Given
        let expectation = self.expectation(description: "AStar finds path")

        let grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 5, z: 5)
        let goal = GridPosition(x: 2, z: 4)


        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: grid).sink { completion in
            switch completion {
                case .finished:
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail()
                }
        } receiveValue: { value in
            switch value {
            case .foundPath(let path):

                XCTAssertEqual(path.count, 4)
            default:
                break
            }
        }

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
    }


    func testFindPathWhenPartiallyBlocked() {
        // Given
        let expectation = self.expectation(description: "AStar finds path")

        var grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 4)
        grid.grid[1][3] = 3
        grid.grid[2][3] = 3
        grid.grid[3][3] = 3


        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: grid).sink { completion in
            switch completion {
                case .finished:
                    expectation.fulfill()
                    break
                case .failure(_):
                    XCTFail()
                }
        } receiveValue: { value in
            switch value {
            case .foundPath(let path):
                print(path)
                XCTAssertEqual(path.count, 5)
            default:
                break
            }
        }

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDoesntFindPathWhenCompletelyBlocked() {
        // Given
        let expectation = self.expectation(description: "AStar finds path")

        var grid = SquareGrid(size: 10)
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 4)
        grid.grid[0][3] = 3
        grid.grid[1][3] = 3
        grid.grid[2][3] = 3
        grid.grid[3][3] = 3
        grid.grid[4][3] = 3
        grid.grid[5][3] = 3
        grid.grid[6][3] = 3
        grid.grid[7][3] = 3
        grid.grid[8][3] = 3
        grid.grid[9][3] = 3

        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: grid).sink { completion in
            switch completion {
                case .finished:
                    XCTFail()
                    break
                case .failure(_):
                    expectation.fulfill()
                    break
                }
        } receiveValue: { _ in

        }

        // Then
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
