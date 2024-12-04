import SwiftUI

struct ObjectivePanelView: View {
    @EnvironmentObject var appState: AppState
    @State var message = ""
    @State var rotation = 0.0
    @State var x = ""
    @State var z = ""

    @State var x1 = ""
    @State var z1 = ""
    @State var x2 = ""
    @State var z2 = ""
    @State var result = ""

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

            Toggle(isOn: $appState.virtualRobitBrain.objectiveInteractor.moveTo) {
                Text("move to")
            }

            Toggle(isOn: $appState.virtualRobitBrain.objectiveInteractor.showPath) {
                Text("show path")
            }

            Button {
                appState.virtualRobitBrain.mapController.clearGrid()
            } label: {
                Text("clear")
            }



            Button {
                if let x1Int = Int(x1), let z1Int = Int(z1), let x2Int = Int(x2), let z2Int = Int(z2) {

                    let isClear = AStarPathfinder.pathClear(p1: GridPosition(x: x1Int, z: z1Int), p2: GridPosition(x: x2Int, z: z2Int), grid: appState.virtualRobitBrain.mapController.grid)
                    result = "\(isClear)"
                    print("path clear \(isClear)")
                }

            } label: {
                Text("check clear")
            }
            Text(result)

            HStack {
                TextField(text: $x1) {
                    Text("x:")
                }
                TextField(text: $z1) {
                    Text("z:")
                }

                TextField(text: $x2) {
                    Text("x:")
                }
                TextField(text: $z2) {
                    Text("z:")
                }
            }
        }
    }
}

#Preview {
    ObjectivePanelView()
}
