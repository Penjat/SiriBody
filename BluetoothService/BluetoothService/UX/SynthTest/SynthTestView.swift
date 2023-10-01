import SwiftUI

struct SynthTestView: View {
    @StateObject var viewModel: SynthTestViewModel
    var body: some View {
        VStack {
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
}

//struct SynthTestView_Previews: PreviewProvider {
//    static var previews: some View {
//        SynthTestView()
//    }
//}
