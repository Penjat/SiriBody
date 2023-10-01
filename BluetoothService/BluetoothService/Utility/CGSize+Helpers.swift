import Foundation

extension CGSize {
    var center: CGPoint {
        CGPoint(x: self.width/2, y: self.height/2)
    }
}
