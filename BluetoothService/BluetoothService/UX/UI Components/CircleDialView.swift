import SwiftUI

struct CircleDialView: View {
    let value: UInt8
    let maxValue: Int

    var body: some View {
        Circle().overlay{
            Rectangle()
                .fill(.yellow)
                .frame(width: 10, height: 30)
                .offset(y: 10)
                .rotationEffect(angle)

        }.frame(width: 50)
    }

    var angle: Angle {
        return Angle(degrees: Double(value) / Double(maxValue) * 360)
    }
}

struct CircleDialView_Previews: PreviewProvider {
    static var previews: some View {
        CircleDialView(value: 0, maxValue: 256)
    }
}
