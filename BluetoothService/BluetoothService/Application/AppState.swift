import Foundation
import Combine

class AppState: ObservableObject {
    lazy var synth = Synth()
    lazy var gloveDataService = GloveDataService()
    lazy var motionService = MotionService()
}
