import SwiftUI

struct TitleView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .trailing, spacing: 20) {
                        Text("Power Glove+🩶")
                            .bold()
                            .font(.largeTitle)
                        Spacer().frame(height: 40)
                        NavigationLink("Glove Synth", destination:
                                        GloveSynthView(viewModel: gloveSynthViewModel))
                        NavigationLink("Synth Test", destination:
                                        SynthTestView(viewModel: synthTestViewModel))
                        NavigationLink("Glove Status", destination:
                                        GloveStatusView(viewModel: gloveStatusViewModel))
                    }.font(.title)
                    Rectangle()
                        .fill(.gray)
                        .opacity(0.4)
                        .frame(width: 8)
                }
                Spacer()
            }
        }
    }

    var gloveSynthViewModel: GloveSynthViewModel {
        GloveSynthViewModel(
            synth: appState.synth,
            gloveService: appState.gloveDataService)
    }

    var gloveStatusViewModel: GloveStatusViewModel {
        GloveStatusViewModel(gloveService: appState.gloveDataService)
    }

    var synthTestViewModel: SynthTestViewModel {
        SynthTestViewModel(synth: appState.synth, motionService: appState.motionService)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
