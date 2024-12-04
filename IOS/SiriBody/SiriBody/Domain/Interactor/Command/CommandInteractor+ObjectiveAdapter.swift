import Foundation
import Combine


extension CommandInteractor {
    func subscribeTo(objectiveOutputPublisher: any Publisher<ObjectiveOutput, Never>) {

        objectiveOutputPublisher
            .eraseToAnyPublisher()
            .compactMap { output in
                switch output {
                case .followPath(let path):
                    return CommandInteractor.sesquenceFrom(path: path)
                }
            }.assign(to: &$sequence)
    }

    static func sesquenceFrom(path: [GridPosition]) -> [SequenceStep] {
        
        return path
            .map { point in
                let x = Double(point.x)*Double(RobitMap.gridResolution)
                let z = Double(point.z)*Double(RobitMap.gridResolution)
                return   .runCommand(.moveTo(x: x, z: z))
            }
    }
}
