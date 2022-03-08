import SwiftUI

struct CommandsView: View {
    @EnvironmentObject var viewModel: DevicesViewModel
    var body: some View {
        VStack {
            Button {
                viewModel.turn90Degrees()
            } label: {
                Text("90°")
            }

        }
    }
}

struct CommandsView_Previews: PreviewProvider {
    static var previews: some View {
        CommandsView()
    }
}
