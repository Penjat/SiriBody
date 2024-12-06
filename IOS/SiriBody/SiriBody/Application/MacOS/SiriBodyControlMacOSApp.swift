import SwiftUI

@main
struct SiriBodyControlMacOSApp: App {
    let appState = AppState()
    var body: some Scene {
        Window("First Window", id: "window1") {
            ControlView()
                .environmentObject(appState)
                .environmentObject(appState.sceneKitService)
                .environmentObject(appState.virtualRobitBrain)
        }
    }
}
