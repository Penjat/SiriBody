import Foundation
import Combine

enum ObjectiveOutput {
    case followPath([GridPosition])
    // watch for _____
    // play sound
}

class ObjectiveInteractor: ObservableObject {
    @Published var objective: Objective?
    
    let output = PassthroughSubject<ObjectiveOutput, Never>()

    var bag = Set<AnyCancellable>()
    private var pathfindingCancellable: AnyCancellable?

    init(statePublisher: AnyPublisher<GridPosition, Never>, robitMap: RobitMap) {
        $objective
            .combineLatest(statePublisher)
            .sink { [weak self] objective, robitGridPosition in

                guard let self else {
                    return
                }

                switch objective {
                case .navigateTo(let goal):
                    subscribeToPathfinder(
                        startingTile: robitGridPosition,
                        goal: goal,
                        robitMap: robitMap)

                case .none:
                    break
                }
            }
            .store(in: &bag)
    }

    func subscribeToPathfinder(startingTile: GridPosition, goal: GridPosition, robitMap: RobitMap) {

        pathfindingCancellable = AStarPathfinder
            .findPath(
                startingTile: startingTile,
                goal: goal,
                grid: robitMap.grid)
            .sink { completion in
                switch completion {
                case .finished:
                    print("path found")

                case .failure(let error):
                    print("Error: no path found")
                    break
                }
            } receiveValue: { [weak self] event in

                guard let self else {
                    return
                }

                switch event {

                case .findingPath(posibleTiles: let possibleTiles, visitedTiles: let visitedTiles):


                    // TODO: publish somewhere to see progress
                    break

                case .foundPath(let path):
                    objective = nil
                    self.output.send(.followPath(path.reversed()))

                    print("path: \(path) ")
                    path.forEach { possition in
                        robitMap.setTile(value: 1, x: possition.x, z: possition.z)
                    }
                }
            }
    }
}
