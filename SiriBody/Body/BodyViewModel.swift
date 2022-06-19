import Foundation
import Combine

class BodyViewModel: ObservableObject {
    @Published var selectedInput = BodyInput.Mock
    @Published var selectedOutput = BodyOutput.Mock
}
