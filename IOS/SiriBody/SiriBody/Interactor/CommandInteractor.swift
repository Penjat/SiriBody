import Foundation
import Combine

class CommandInteractor: ObservableObject {
    @Published var sendToVirtual = true
    @Published var sendToPhysical = false
    
    let input = CurrentValueSubject<Command?, Never>(nil)
}
