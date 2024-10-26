import Foundation
import SwiftUI
import SceneKit
import Combine

struct SceneKitView: NSViewRepresentable {
    let interactor: SceneKitService
    @State var bag = Set<AnyCancellable>()
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero)
        sceneView.scene = interactor.scene
        sceneView.backgroundColor = NSColor.darkGray
        sceneView.delegate = interactor

        return sceneView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {}
}
