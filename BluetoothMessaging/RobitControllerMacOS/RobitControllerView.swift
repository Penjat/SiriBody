import SwiftUI

struct RobitControllerView: View {
    @StateObject var viewModel = RobitControllerViewModel()
    
    var body: some View {
        VStack {
            Group {
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
                
                Button("just left") {
                    viewModel.centralService.commandSubject.send(Command.justLeft.data())
                }
                
                Button("just right") {
                    viewModel.centralService.commandSubject.send(Command.justRight.data())
                }
            }
            
            Divider()
            
            Group {
                Button("just right") {
                    viewModel.centralService.commandSubject.send(Command.justRight.data())
                }
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
