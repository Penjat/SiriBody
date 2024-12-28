import SwiftUI

struct RobitStatusView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Spacer()
                VStack {
                    Text("Motor R")
                    Text("\(appState.robitBrain.motorSpeed.motor1 > 0 ? "+" : "")\(appState.robitBrain.motorSpeed.motor1)")
                }
                
                Spacer()
                VStack {
                    Text("Motor L")
                    Text("\(appState.robitBrain.motorSpeed.motor2 > 0 ? "+" : "")\(appState.robitBrain.motorSpeed.motor2)")
                }
                
                Spacer()
            }
            
            Text("x: \(appState.robitBrain.state.position.x > 0 ? "+" : "")\(appState.robitBrain.state.position.x, specifier: "%.2f"), z: \(appState.robitBrain.state.position.z > 0 ? "+" : "")\(appState.robitBrain.state.position.z, specifier: "%.2f")").monospaced()
                
            Text("Roll: \(appState.robitBrain.state.orientation.z > 0 ? "+" : "")\(appState.robitBrain.state.orientation.z, specifier: "%.2f")").monospaced()
            
        }
    }
}

#Preview {
    RobitStatusView()
}
