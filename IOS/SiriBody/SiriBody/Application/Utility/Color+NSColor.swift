import Foundation
import SwiftUI

extension Color {
    func toNSColor() -> NSColor? {
        guard let cgColor = self.cgColor, let nsColor = NSColor(cgColor: cgColor) else {
            return nil
        }
        return nsColor
    }
}
