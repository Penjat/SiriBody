import SwiftUI

struct BodyView: View {
    @StateObject var viewModel = BodyViewModel()
    @State var menuOpen = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    menuOpen = true
                } label: {
                    Text("menu")
                }
            }
            BodyInputView()
            Spacer()
            Text("Orientation")
            Spacer()
            BodyOutputView()
            
        }
        .environmentObject(viewModel)
        .padding()
        .sheet(isPresented: $menuOpen) {
            
        } content: {
            BodyMenuView()
        }.environmentObject(viewModel)
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView()
    }
}
