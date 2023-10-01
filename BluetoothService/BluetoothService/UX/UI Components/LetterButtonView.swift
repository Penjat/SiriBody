import SwiftUI

struct LetterButtonView: View {
    let color: Color
    let text: String
    let size: CGFloat
    let isPressed: Bool

    var body: some View {
        ZStack {
            Circle().fill(.black)
            Circle()
                .fill(color)
                .opacity(isPressed ? 1.0 : 0.6)
                .overlay{
                    Text(text)
                        .foregroundColor(.white)
                        .font(.title).bold()
                }
                .padding(4)
        }.frame(width: size)
    }
}

struct LetterButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LetterButtonView(color: .red, text: "A", size: 80, isPressed: true)
    }
}
