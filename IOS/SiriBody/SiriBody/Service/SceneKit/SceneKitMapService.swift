import Foundation
import SceneKit
import Combine

class SceneKitMapService: ObservableObject {
    let scene: SCNScene
    var gridTiles: [[SCNNode]] = []

    let xOffset = 50
    let zOffset = 50

    init(scene: SCNScene) {
        self.scene = scene
    }

    func createMap(from grid: [[UInt8]] ) {
        
        var x = 0
        var z = 0
        for row in grid {
            var newRow = [SCNNode]()
            for col in row {

                let color = colorForTile(number: col)
                let tile = createTile(color: color)
                scene.rootNode.addChildNode(tile)
                tile.position = SCNVector3(x-xOffset, 0, z-zOffset)
                newRow.append(tile)
                x += 1
            }
            x = 0
            z += 1
            gridTiles.append(newRow)
        }
    }

    func colorForTile(number: UInt8) -> NSColor {
        switch number {
        case 0:
            return NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
        case 1:
            return NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        case 2:
            return NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.2)
        case 3:
            return NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.2)
        default:
            return NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)
        }
    }

    func updateTile(x: Int, z: Int, color: NSColor) {
        guard let materials = gridTiles[z+zOffset][x+xOffset].geometry?.materials else {
            return
        }


        for material in materials {
            material.diffuse.contents = color
        }
    }

    private func createTile(color: NSColor) -> SCNNode {
        let boxGeometry = SCNBox(width: 0.9, height: 0.1, length: 0.9, chamferRadius: 0.0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = color
        boxGeometry.materials = [boxMaterial]


        let boxNode = SCNNode(geometry: boxGeometry)
        
        return boxNode
    }
}
