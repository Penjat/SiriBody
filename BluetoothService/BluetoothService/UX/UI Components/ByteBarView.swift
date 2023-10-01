import SwiftUI

struct ByteBarView: View {
    let color: Color
    let number: Int
    var body: some View {
        Path { path in
            for i in 0..<number {
                let yPos = CGFloat(i*8)
                path.move(to: CGPoint(x: 0.0, y: yPos ))
                path.addLine(to: CGPoint(x: 40.0, y: yPos))
            }
        }.stroke(color, lineWidth: 1).frame(width: 60, height: 200)
    }
}

struct ByteBarView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ByteBarView(color: .red, number: 20)
            ByteBarView(color: .orange, number: 32)
            ByteBarView(color: .blue, number: 8)
        }
    }
}
