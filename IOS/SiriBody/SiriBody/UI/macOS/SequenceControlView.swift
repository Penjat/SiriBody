import SwiftUI

struct SequenceControlView: View {
    @ObservedObject var sequenceController: SequenceController
    var body: some View {
        VStack {
            Button {
                    sequenceController
                    .startSquareSequence()
            } label: {
                Text("Square")
            }

            Button {
                    sequenceController
                    .startLineSequence()
            } label: {
                Text("line")
            }

            Button {
                    sequenceController
                    .motionCommand = nil
            } label: {
                Text("Stop")
            }

            Button {
                    sequenceController
                    .runStep()
            } label: {
                Text("resume")
            }
        }
    }
}

