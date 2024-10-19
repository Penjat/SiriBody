import SwiftUI

@main
struct SiriBodyControlMacOSApp: App {
    let appState = AppState()
    @State var motorSpeed = (motor1Speed: 0, motor2Speed: 0)
    var body: some Scene {
        Window("First Window", id: "window1") {
            ControlView()
                .environmentObject(appState)
                .environmentObject(appState.centralService)
                .environmentObject(appState.robitPositionService)
                .environmentObject(appState.sceneKitInteractor)
                .environmentObject(appState.virtualRobitInteractor)
        }
    }
}
