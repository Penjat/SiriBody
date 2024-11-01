import SwiftUI

struct ObjectivePanelView: View {
    @EnvironmentObject var appState: AppState
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var z = ""

    var body: some View {
        VStack {

            HStack {
                TextField(text: $x) {
                    Text("x:")
                }
                TextField(text: $z) {
                    Text("z:")
                }
            }
            Button {
                if let xInt = Int(x), let zInt = Int(z) {
                    print("\(xInt), \(zInt)")
                    appState.virtualRobitBrain.objectiveInteractor.objective = Objective.navigateTo(GridPosition(x: xInt, z: zInt))
                }

            } label: {
                Text("set target")
            }

            Button {
                appState.virtualRobitBrain
            } label: {
                Text("clear")
            }

        }
    }
}

#Preview {
    ObjectivePanelView()
}
