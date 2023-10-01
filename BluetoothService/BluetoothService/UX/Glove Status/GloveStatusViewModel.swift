import Foundation
import Combine

class GloveStatusViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()

    @Published var gloveState: PowerGloveDataObject?

    init(gloveService: GloveDataService) {
        gloveService.$gloveState.assign(to: &$gloveState)
    }
}
