import Foundation
import Combine

extension PIDControlView {
    
    enum ControlMode: String, CaseIterable {
        case user
        case pid
        case robit
    }

    class ViewModel: ObservableObject {




        @Published var controlMode: ControlMode = .user
        @Published var pidControlOn = false

    }
}
