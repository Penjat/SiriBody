import Foundation
import Combine

class GloveViewModel: ObservableObject {
    var gloveService = GloveDataService()
    var bag = Set<AnyCancellable>()

    @Published var gloveState: PowerGloveDataObject?

    init() {
        gloveService.$gloveState.assign(to: &$gloveState)
    }
}
