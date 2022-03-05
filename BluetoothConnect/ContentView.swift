import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DevicesViewModel = .init()
    var body: some View {
        
            VStack(spacing: 40){
                HStack {
                    Text("\(viewModel.motor1Speed)")
                    Spacer()
                    Text("\(viewModel.motor2Speed)")
                }
                Spacer()
                HStack {
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 150, height: 500)
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    
                                    print("Touch down \(value.location.y)")
                                    viewModel.motor1Speed = 250 - value.location.y
                                }
                                .onEnded { value in
                                    viewModel.motor1Speed = 0
                                }
                        )
                    
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 150, height: 500)
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    
                                    print("Touch down \(value.location.y)")
                                    viewModel.motor2Speed = 250 - value.location.y
                                }
                                .onEnded { value in
                                    viewModel.motor2Speed = 0
                                }
                        )
                }
                
                Spacer()
        
        
//            Button {
//                viewModel.sendMessage("f")
//            } label: {
//                Text("forward")
//            }
//
//            Button {
//                viewModel.sendMessage("s")
//            } label: {
//                Text("stop")
//            }
//
//            Button {
//                viewModel.sendMessage("b")
//            } label: {
//                Text("backwards")
//            }

        }
        
            .padding()
            .onAppear {
                viewModel.start()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
