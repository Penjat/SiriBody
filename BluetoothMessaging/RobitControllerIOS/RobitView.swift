import SwiftUI

struct RobitView: View {
    @StateObject var viewModel = RobitViewModel()
    var body: some View {
        Text("Robit")
        ForEach(viewModel.reciededData, id: \.self) { text in
            Text(text)
        }
    }
}

struct RobitView_Previews: PreviewProvider {
    static var previews: some View {
        RobitView()
    }
}
