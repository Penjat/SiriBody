import SwiftUI

struct TitleView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                NavigationLink {
                    PeripheralView()
                } label: {
                    Text("Peripheral")
                }
                NavigationLink {
                    CenterView()
                } label: {
                    Text("center")
                }
            }
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
