import SwiftUI

struct RobitControllerView: View {
    @StateObject var viewModel = RobitControllerViewModel()
    
    var body: some View {
        VStack {
            Button("north") {
                viewModel.centralService.commandSubject.send(Command.faceNorth.data())
            }
            Button("south") {
                viewModel.centralService.commandSubject.send(Command.faceSouth.data())
            }
            Button("east") {
                viewModel.centralService.commandSubject.send(Command.faceEast.data())
            }
            Button("west") {
                viewModel.centralService.commandSubject.send(Command.faceWest.data())
            }
            
            Button("forward") {
                viewModel.centralService.commandSubject.send(Command.moveForward.data())
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
