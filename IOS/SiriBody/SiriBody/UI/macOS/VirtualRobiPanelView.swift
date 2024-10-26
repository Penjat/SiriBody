import SwiftUI
import SceneKit

struct VirtualRobiPanelView: View {
    @EnvironmentObject var virtualRobitBrain: RobitBrain
    @EnvironmentObject var sceneKitInteractor: SceneKitService
    var body: some View {
        VStack {
            Text("Virtual Robit")
            HStack {
                Button {
                    sceneKitInteractor.resetVirtualRobitPosition()
                } label: {
                    Text("(0,0)")
                }
                Button {
                    sceneKitInteractor.resetVirtualRobitPosition(sceneKitInteractor.realRobit?.position ?? SCNVector3(x: 0, y: 0, z: 0), sceneKitInteractor.realRobit?.eulerAngles ?? SCNVector3(x: 0, y: 0, z: 0))
                } label: {
                    Text("real robit")
                }
                
            }
            commandText

        }.padding().background(.thinMaterial).cornerRadius(8, antialiased: true)
    }

    var commandText: some View {
        if let command = virtualRobitBrain.sequenceController.motionCommand {
            switch command {
            case .turnTo(let angle):
                Text("turnTo \(angle)")
            case .moveTo(let x, let z):
                Text("moveTo: (\(x), \(z))")
            }
        } else {
            Text("no command")
        }
    }
}

#Preview {
    VirtualRobiPanelView()
}
