import SwiftUI

struct RobitStatusView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("x: \(appState.robitBrain.state.position.x, specifier: "%.2f"), z: \(appState.robitBrain.state.position.z, specifier: "%.2f")")
                
            Text("Roll: \(appState.robitBrain.state.orientation.z, specifier: "%.2f")")
            
            HStack {
                Spacer()
                Text("\(appState.robitBrain.motorSpeed.motor1)")
                Spacer()
                Text("\(appState.robitBrain.motorSpeed.motor2)")
                Spacer()
            }
        }
    }
}

#Preview {
    RobitStatusView()
}
