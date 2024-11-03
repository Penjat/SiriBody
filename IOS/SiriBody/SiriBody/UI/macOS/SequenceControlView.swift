import SwiftUI

struct SequenceControlView: View {
    @ObservedObject var sequenceController: CommandInteractor
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
                    .runStep(sequence: sequenceController.sequence)
            } label: {
                Text("resume")
            }
        }
    }
}

