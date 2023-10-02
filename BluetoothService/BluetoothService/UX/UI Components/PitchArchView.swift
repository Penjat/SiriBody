import SwiftUI

struct PitchArcView: View {
    let pitchNames: [String]
    let selectedNote: Int
    let lowerBound: Int
    let upperBound: Int

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2.0
            let angleStep = .pi / Double(upperBound-lowerBound)

            ZStack {
                ForEach(lowerBound...upperBound, id: \.self) { note in
                    let angle = Double(note) * angleStep
                    let x = radius * cos(angle)
                    let y = radius * sin(angle)
                    let fontSize: CGFloat = note == selectedNote ? 24 : 8
                    if note == selectedNote {
                        Text(pitchNames[note % pitchNames.count])
                            .font(.system(size: fontSize))
                            .position(x: x + radius, y: y + radius)
                    } else {
                        Circle()
                            .fill(.blue)
                            .frame(width: 4)
                            .position(x: x + radius, y: y + radius)
                    }
                }
                Text(pitchNames[selectedNote % pitchNames.count]).font(.title2)
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}
