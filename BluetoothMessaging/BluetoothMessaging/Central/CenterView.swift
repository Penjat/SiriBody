import SwiftUI

struct CenterView: View {
    @StateObject var viewModel = CentrerViewModel()
    var body: some View {
        VStack {
            Text("message from sender:")
            Text("\(viewModel.text)")
            
        }
    }
}

struct CenterView_Previews: PreviewProvider {
    static var previews: some View {
        CenterView()
    }
}
