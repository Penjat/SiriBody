import SwiftUI

@main
struct SiriBodyApp: App {
    let appState = AppState()
    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(appState)
                .environmentObject(appState.centralService)
        }
    }
}
