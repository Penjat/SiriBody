import Foundation
import Combine


extension CommandInteractor {
    func subscribeTo(objectiveOutputPublisher: any Publisher<ObjectiveOutput, Never>) {

        objectiveOutputPublisher
            .eraseToAnyPublisher()
            .compactMap { output in
                switch output {
                case .followPath(let path):
                    return nil//CommandInteractor.sesquenceFrom(path: path)
                }
            }.assign(to: &$sequence)
    }

    static func sesquenceFrom(path: [GridPosition]) -> [SequenceStep] {
        
        return path.map { .runCommand(.moveTo(x: Double($0.x), z: Double($0.z))) }
    }
}
