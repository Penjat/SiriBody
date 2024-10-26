import SwiftUI
import SceneKit
import Combine

struct SceneKitView: NSViewRepresentable {
    let interactor: SceneKitService
    @State var bag = Set<AnyCancellable>()
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = interactor.scene
        scnView.backgroundColor = NSColor.darkGray
        scnView.delegate = interactor

        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {}
}
