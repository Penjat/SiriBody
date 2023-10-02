import SwiftUI

struct SynthTestView: View {
    @StateObject var viewModel: SynthTestViewModel
    var body: some View {
        VStack {
            
            PitchArcView(pitchNames: Note.noteNames, selectedNote: viewModel.currentPitch?.noteNumber ?? 69, lowerBound: 40, upperBound: 81)
            Text("roll: \(viewModel.rotation)")
            Slider(value: $viewModel.finger0)
            Slider(value: $viewModel.finger1)
            Slider(value: $viewModel.finger2)
            HStack {
                LetterButtonView(color: .red, text: "A", size: 60, isPressed: viewModel.pressedA)
                LetterButtonView(color: .yellow, text: "B", size: 60, isPressed: viewModel.pressedB)
                LetterButtonView(color: .green, text: "C", size: 60, isPressed: viewModel.pressedC)
            }
        }.padding(40)
    }

    var possibleNotes: [String] {
        []
    }


//    var freqency: Double {
//        if rotation < -
//    }
}

//struct SynthTestView_Previews: PreviewProvider {
//    static var previews: some View {
//        SynthTestView()
//    }
//}
