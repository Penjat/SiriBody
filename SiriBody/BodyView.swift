import SwiftUI

struct BodyView: View {
    var body: some View {
        VStack {
            BodyInputView().padding()
            Text("Siri Body")
            BodyOuputView().padding()
        }
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView()
    }
}
