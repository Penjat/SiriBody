import SwiftUI

struct CommandView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        switch appState.robitBrain.sequenceController.motionCommand {
        case .turnTo(angle: let angle):
            VStack {
                Text("turn to: \(angle, specifier: "%.2f"))")
                Text("\(calculateShortestDistance(currentAngle:Double( appState.robitBrain.state.orientation.z), desiredHeading: angle), specifier: "%.2f")")
            }

        case .none:
            Text("no command")
        case .moveTo(x: let x, z: let z):
            Text("move to \(x),\(z)")
        }
    }
}

#Preview {
    CommandView()
}
