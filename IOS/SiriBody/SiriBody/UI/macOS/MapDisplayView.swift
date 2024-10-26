import SwiftUI

struct MapDisplayView: View {
    @ObservedObject var mapController: MapController

    var body: some View {
        GeometryReader { geometry in

            ForEach(0..<mapController.grid.count, id: \.self) { rowIndex in
                ForEach(0..<mapController.grid[rowIndex].count, id: \.self) { columnIndex in
                    let byte = mapController.grid[rowIndex][columnIndex]
                    let color = colorForByte(byte)
                    let squareSize: CGFloat = 10.0
                    let x = CGFloat(columnIndex) * squareSize
                    let y = CGFloat(rowIndex) * squareSize

                    Path { path in
                        let rect = CGRect(x: x, y: y, width: squareSize, height: squareSize)
                        path.addRect(rect)
                    }
                    .fill(color.opacity(0.4))
                }
            }
        }
    }

    // Function to map byte values to colors
    func colorForByte(_ byte: UInt8) -> Color {
        switch byte {
        case 0:
            return Color.gray
        case 1:
            return Color.red
        case 2:
            return Color.orange
        case 3:
            return Color.yellow
        case 4:
            return Color.green
        default:
            return Color.black // Default color for unexpected byte values
        }
    }
}
