import Foundation
import Combine

class RobitControllerViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()
    var centralService = CentralService()
    @Published var recievedData = [String]()
    @Published var messageText = ""
    init() {
        centralService.data.receive(on: DispatchQueue.main, options: nil).sink { text in
            print("\(text)")
            self.recievedData.append(text)
        }.store(in: &bag)
    }
}
