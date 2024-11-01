import SwiftUI

struct MapDisplayView: View {
    @ObservedObject var mapController: RobitMap
    @Binding var robitState: RobitState

    var body: some View {
        GeometryReader { geometry in
            let robitPos = (x: Int(robitState.position.x)+50, z: Int(robitState.position.z)+50)
            ForEach(0..<mapController.grid.grid.count, id: \.self) { rowIndex in
                ForEach(0..<mapController.grid.grid[rowIndex].count, id: \.self) { columnIndex in
                    let byte = mapController.grid.grid[rowIndex][columnIndex]
                    let color = (rowIndex == robitPos.z && columnIndex == robitPos.x) ? Color.purple :  colorForByte(byte)
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
            return Color.blue
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
