import SwiftUI

@main
struct SiriBodyControlMacOSApp: App {
    let appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ControlView()
                .environmentObject(appState)
                .environmentObject(appState.centralService)
        }
    }
}
