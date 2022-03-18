import SwiftUI

struct ContentView: View {
    @State var currentPage = ViewState.title
    var body: some View {
        PeripheralView()
            .frame(width: 400, height: 400)
    }
}

enum ViewState: String, CaseIterable {
    case peripheral
    case central
    case title
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
