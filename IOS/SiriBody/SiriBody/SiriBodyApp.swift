import SwiftUI

@main
struct SiriBodyApp: App {
    let appState = AppState()
    let movementInteractor = MovementInteractor()
    var body: some Scene {
        WindowGroup {
            TitleView()
                .environmentObject(appState)
                .environmentObject(movementInteractor)
        }
    }
}
