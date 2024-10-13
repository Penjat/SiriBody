import Foundation
import Combine



class GoalInteractor: ObservableObject {
    @Published var targetYaw = 0.0
    @Published var command: Command?
    
}
