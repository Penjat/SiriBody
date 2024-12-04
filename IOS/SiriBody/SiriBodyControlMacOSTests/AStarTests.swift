import XCTest
import Combine

final class AStarTests: XCTestCase {
    func testDistanceFrom() {
        // Given
        var start = GridPosition(x: 2, z: 2)
        var goal = GridPosition(x: 4, z: 4)

        // When
        var distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 4)


        // Given
        start = GridPosition(x: 0, z: 0)
        goal = GridPosition(x: 100, z: 10)

        // When
        distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 110)


        // Given
        start = GridPosition(x: 5, z: 15)
        goal = GridPosition(x: 0, z: 0)

        // When
        distance = AStarPathfinder.distanceFromGoal(tile: start, goal: goal)

        // Then
        XCTAssertEqual(distance, 20)
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
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let startingTile = GridPosition(x: 4, z: 4)

        robitMap.setTile(value: 3, x: 3, z: 3)
        robitMap.setTile(value: 3, x: 4, z: 3)
        robitMap.setTile(value: 3, x: 5, z: 3)

        // When
        let neighbors = robitMap.grid.findPossibleNeighbors(forTile: startingTile)

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
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let startingTile = GridPosition(x: 5, z: 5)
        let goal = GridPosition(x: 2, z: 4)


        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: robitMap.grid).sink { completion in
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

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 4)

        robitMap.setTile(value: 3, x: 1, z: 3)
        robitMap.setTile(value: 3, x: 2, z: 3)
        robitMap.setTile(value: 3, x: 3, z: 3)


        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: robitMap.grid).sink { completion in
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
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 10, z: 10)

        robitMap.setTile(value: 3, x: 1, z: 3)
        robitMap.setTile(value: 3, x: 2, z: 3)
        robitMap.setTile(value: 3, x: 3, z: 3)
        robitMap.setTile(value: 3, x: 1, z: 1)
        robitMap.setTile(value: 3, x: 2, z: 1)
        robitMap.setTile(value: 3, x: 3, z: 1)
        robitMap.setTile(value: 3, x: 3, z: 2)
        robitMap.setTile(value: 3, x: 1, z: 2)

        // When
        let subject = AStarPathfinder.findPath(startingTile: startingTile, goal: goal, grid: robitMap.grid).sink { completion in
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

    func testPathXClearWithEmptyGrid() {
        // Given

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        // When
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 10, z: 2)

        // Then
        XCTAssertTrue(AStarPathfinder.pathClear(p1: startingTile, p2: goal, grid: robitMap.grid))
    }

    func testPathZClearWithEmptyGrid() {
        // Given

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        // When
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 10)

        // Then
        XCTAssertTrue(AStarPathfinder.pathClear(p1: startingTile, p2: goal, grid: robitMap.grid))
    }

    func testPathXClearWithBlockedGrid() {
        // Given

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        // When
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 10, z: 2)
        robitMap.setTile(value: 4, x: 5, z: 2)

        // Then
        XCTAssertFalse(AStarPathfinder.pathClear(p1: startingTile, p2: goal, grid: robitMap.grid))
    }

    func testPathZClearWithBlockedGrid() {
        // Given

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        // When
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 2, z: 10)
        robitMap.setTile(value: 4, x: 2, z: 5)

        // Then
        XCTAssertFalse(AStarPathfinder.pathClear(p1: startingTile, p2: goal, grid: robitMap.grid))
    }

    func testPathClearWithBlockedGrid() {
        // Given

        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())

        // When
        let startingTile = GridPosition(x: 2, z: 2)
        let goal = GridPosition(x: 10, z: 10)
        robitMap.setTile(value: 4, x: 8, z: 8)

        // Then
        XCTAssertFalse(AStarPathfinder.pathClear(p1: startingTile, p2: goal, grid: robitMap.grid))
    }

    func testOptimisePathForEmptyGrid() {
        // Given
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let path = [
            GridPosition(x: 2, z: 2),
            GridPosition(x: 2, z: 3),
            GridPosition(x: 2, z: 4),
            GridPosition(x: 2, z: 5),
            GridPosition(x: 2, z: 6),
            GridPosition(x: 2, z: 7)
        ]

        // When
        let optimizedPath = AStarPathfinder.optimize(path: path, grid: robitMap.grid)

        // Then
        XCTAssertEqual(optimizedPath.count, 2)
    }

    func testOptimiseDiagonalPathForEmptyGrid() {
        // Given
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let path = [
            GridPosition(x: 2, z: 2),
            GridPosition(x: 2, z: 3),
            GridPosition(x: 2, z: 4),
            GridPosition(x: 2, z: 5),
            GridPosition(x: 2, z: 6),
            GridPosition(x: 2, z: 7),

            GridPosition(x: 2, z: 7),
            GridPosition(x: 3, z: 7),
            GridPosition(x: 4, z: 7),
            GridPosition(x: 5, z: 7),
            GridPosition(x: 6, z: 7),
            GridPosition(x: 7, z: 7)
        ]

        // When
        let optimizedPath = AStarPathfinder.optimize(path: path, grid: robitMap.grid)

        // Then
        XCTAssertEqual(optimizedPath.count, 2)
    }

    func testOptimiseForBlockedGrid() {
        // Given
        let statePublisher = PassthroughSubject<RobitState, Never>()
        let robitMap = RobitMap(statePublisher: statePublisher.eraseToAnyPublisher())
        let path = [
            GridPosition(x: 2, z: 2),
            GridPosition(x: 2, z: 3),
            GridPosition(x: 3, z: 4),
            GridPosition(x: 2, z: 5),
            GridPosition(x: 2, z: 6),
            GridPosition(x: 2, z: 7),
        ]

        robitMap.setTile(value: 4, x: 2, z: 4)

        // When
        let optimizedPath = AStarPathfinder.optimize(path: path, grid: robitMap.grid)

        // Then
        XCTAssertEqual(optimizedPath.count, 3)
        
    }
}
