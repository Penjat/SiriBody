import SwiftUI

struct RobitView: View {
    @StateObject var viewModel = RobitViewModel()
    var body: some View {
        VStack {
            Text("Robit").font(.title)
            Button("start") {
                viewModel.motionService.goal.send(.waitFor(time: Date.timeIntervalSinceReferenceDate + 1))
            }
            ForEach(viewModel.reciededData, id: \.self) { text in
                Text(text)
            }
        }
        
    }
}

struct RobitView_Previews: PreviewProvider {
    static var previews: some View {
        RobitView()
    }
}
