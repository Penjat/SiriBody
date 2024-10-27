import Foundation
import SwiftUI
import SceneKit
import Combine

struct SceneKitView: NSViewRepresentable {
    let interactor: SceneKitService
    @State var bag = Set<AnyCancellable>()

    func makeNSView(context: Context) -> SCNView {
        let sceneView = CustomSCNView(frame: .zero)
        sceneView.scene = interactor.scene
        sceneView.backgroundColor = NSColor.darkGray
        sceneView.delegate = interactor
        sceneView.touchHandler = context.coordinator

        return sceneView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(interactor: interactor)
    }

    class Coordinator {
        let interactor: SceneKitService
        init(interactor: SceneKitService) {
            self.interactor = interactor
        }
        func handleTouches(at point: CGPoint, in view: SCNView) {
            let hitResults = view.hitTest(point, options: nil)
            if let hit = hitResults.first {
                let position = hit.worldCoordinates
                // Use 'position' as the location in SceneKit
                interactor.eventSubject.send(SceneKitService.SceneEvent.touchPoint(x: position.x, z: position.z))
                print(position)

            }
        }
    }
}

class CustomSCNView: SCNView {
    var touchHandler: SceneKitView.Coordinator?

    override init(frame: NSRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let locationInWindow = event.locationInWindow
        let pointInView = self.convert(locationInWindow, from: nil)
        touchHandler?.handleTouches(at: pointInView, in: self)
    }
}
