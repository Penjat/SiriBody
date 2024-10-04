import SwiftUI

struct CommandsView: View {
    @EnvironmentObject var viewModel: DevicesViewModel
    var body: some View {
        VStack(spacing: 40) {
            Text("\(viewModel.turnTime)")
            Slider(value: $viewModel.turnTime, in: 0.2...2.0)
            Button {
                
                let data = Data([14 + (14 << 4)])
                viewModel.dataSubject.send(data)
                
            } label: {
                Text("forward")
            }
            
            Button {
                let data = Data([0 + (0 << 4)])
                viewModel.dataSubject.send(data)
            } label: {
                Text("backward")
            }

            Button {
                let data = Data([7 + (7 << 4)])
                viewModel.dataSubject.send(data)
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
