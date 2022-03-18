import SwiftUI

struct RobitControllerView: View {
    @StateObject var viewModel = RobitControllerViewModel()
    
    var body: some View {
        VStack {
            Button("turn 360") {
                viewModel.centralService.commandSubject.send(Command.turn360.data())
            }
        }
        .frame(width: 500, height: 500)
    }
}

struct RobitControllerView_Previews: PreviewProvider {
    static var previews: some View {
        RobitControllerView()
    }
}
