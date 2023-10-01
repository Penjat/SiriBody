import SwiftUI

extension Color {
    static func lerp(from startColor: Color, to endColor: Color, fraction fraction1: CGFloat) -> Color {
        var fraction = max(0.0, min(1.0, fraction1)) // Clamp fraction between 0 and 1

        let startComponents = startColor.cgColor?.components ?? [0, 0, 0, 1]
        let endComponents = endColor.cgColor?.components ?? [0, 0, 0, 1]

        let interpolatedRed = startComponents[0] + fraction * (endComponents[0] - startComponents[0])
        let interpolatedGreen = startComponents[1] + fraction * (endComponents[1] - startComponents[1])
        let interpolatedBlue = startComponents[2] + fraction * (endComponents[2] - startComponents[2])
        let interpolatedAlpha = startComponents[3] + fraction * (endComponents[3] - startComponents[3])

        return Color(red: Double(interpolatedRed), green: Double(interpolatedGreen), blue: Double(interpolatedBlue), opacity: 1)
    }
}

// Example usage:
let startColor = Color.red
let endColor = Color.blue
let fraction: CGFloat = 0.5 // Interpolate halfway between start and end colors

let interpolatedColor = Color.lerp(from: startColor, to: endColor, fraction: fraction)

// Use the interpolatedColor as needed in your SwiftUI views
