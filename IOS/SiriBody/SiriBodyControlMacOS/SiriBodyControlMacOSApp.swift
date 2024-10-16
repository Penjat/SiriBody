import SwiftUI

@main
struct SiriBodyControlMacOSApp: App {
    let appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ControlView()
                .environmentObject(appState)
                .environmentObject(appState.centralService)
                .environmentObject(appState.robitPositionService)
            
//            SceneKitView()
//                        .frame(minWidth: 400, minHeight: 400)
        }
    }
}
