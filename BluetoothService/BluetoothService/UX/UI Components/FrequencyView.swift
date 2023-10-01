import SwiftUI

struct FrequencyView: View {
    let numberSamples = 200
    let wav: (Double) -> Double

    var body: some View {
        GeometryReader { geometry in
            let center = geometry.size.center
            Path { path in
                path.move(to: CGPoint(x: 0.0, y: center.y))
                for i in 0..<numberSamples {
                    let x = Double(i)*geometry.size.width/Double(numberSamples)
                    let y = (wav(Double(i)*Double.pi*2/Double(numberSamples))*200.0) + center.y
                    path.addLine(to: CGPoint(x: x, y: y))
                }

            }.stroke(.blue, lineWidth: 4)
        }
    }
}

struct FrequencyView_Previews: PreviewProvider {
    static var previews: some View {
        FrequencyView(wav: sin)
    }
}
