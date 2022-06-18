import SwiftUI

enum BodyOutput: String, CaseIterable {
    case Mock
    case BlueTooth
}

struct BodyOuputView: View {
    @State var selectedOutput = BodyOutput.Mock
    var body: some View {
        VStack {
            Picker(selection: $selectedOutput) {
                ForEach(BodyOutput.allCases, id: \.rawValue) { outputType in
                    Text(outputType.rawValue).tag(outputType)
                }
            } label: {
                Text("Output select")
            }.pickerStyle(SegmentedPickerStyle())
            
            switch selectedOutput {
            case .Mock:
                Text("Mock Body")
            case .BlueTooth:
                Text("Blue tooth")
            }
        }
        .border(Color.blue, width: 4)
            .cornerRadius(8.0)
    }
}

struct BodyOuputView_Previews: PreviewProvider {
    static var previews: some View {
        BodyOuputView()
    }
}
