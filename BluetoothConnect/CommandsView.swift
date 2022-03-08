import SwiftUI

struct CommandsView: View {
    @EnvironmentObject var viewModel: DevicesViewModel
    var body: some View {
        VStack(spacing: 40) {
            Text("\(viewModel.turnTime)")
            Slider(value: $viewModel.turnTime, in: 0.2...2.0)
            Button {
                viewModel.turn90Degrees()
            } label: {
                Text("90°")
            }
            
            Button {
                viewModel.makeSquare()
            } label: {
                Text("square")
            }

            Button {
                viewModel.stopMotion()
            } label: {
                Text("stop")
            }
        }
    }
}

struct CommandsView_Previews: PreviewProvider {
    static var previews: some View {
        CommandsView()
    }
}
