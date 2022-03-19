import SwiftUI

struct RobitView: View {
    @StateObject var viewModel = RobitViewModel()
    var body: some View {
        VStack {
//            HStack {
//                Text("\(viewModel.possitionData?.attitude.pitch ?? 0)")
//                Text("\(viewModel.possitionData?.attitude.yaw ?? 0)")
//                Text("\(viewModel.possitionData?.attitude.roll ?? 0)")
//                
//            }.font(.title3)
            
            Button("move robit") {
                let data = Data([235, UInt8(min(255,60)), UInt8(min(255,60))])
                
                viewModel.centralService.commandSubject.send(data)
            }
            Text("Robit")
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
