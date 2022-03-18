import Foundation
import Combine

class RobitViewModel: ObservableObject {
    let peripheralService = PeripheralService()
    @Published var messageText = ""
    @Published var reciededData = [String]()
    var bag = Set<AnyCancellable>()
    
    init() {
        peripheralService.dataIN.receive(on: DispatchQueue.main, options: nil).sink { text in
            self.reciededData.append(text)
        }.store(in: &bag)
    }
}
