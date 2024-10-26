import SwiftUI

struct SequenceControlView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack {
            Button {
                appState.virtualRobitBrain.sequenceController.startSquareSequence()
            } label: {
                Text("Start Square Sequence")
            }

        }
    }
}

#Preview {
    SequenceControlView()
}
