import SwiftUI
import SceneKit

struct VirtualRobiPanelView: View {
    @EnvironmentObject var sceneKitInteractor: SceneKitInteractor
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
        }.padding().background(.thinMaterial).cornerRadius(8, antialiased: true)
    }
}

#Preview {
    VirtualRobiPanelView()
}
