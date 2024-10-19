import SwiftUI
import SceneKit
import Combine

struct SceneKitView: NSViewRepresentable {
    
    @ObservedObject var interactor: SceneKitInteractor
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.scene = interactor.scene

        scnView.allowsCameraControl = true
        scnView.backgroundColor = NSColor.darkGray
        
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {}
}
