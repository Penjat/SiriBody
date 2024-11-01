import Foundation
import SceneKit
import Combine

class SceneKitMapDisplayService: ObservableObject {
    let scene: SCNScene
    var gridTiles: [[SCNNode]] = []
    let mapController: RobitMap

    let xOffset = 100
    let zOffset = 100
    var bag = Set<AnyCancellable>()

    init(scene: SCNScene, mapController: RobitMap) {
        self.scene = scene
        self.mapController = mapController
        createMap(from: mapController.grid)
        mapController
            .events
            .sink { [weak self] event in
                
            switch event {
            case .updateTiles(let tileUpdates):
                for (value, position) in tileUpdates {
                    self?.updateTile(x: position.x, z: position.z, color: SceneKitMapDisplayService.colorForTile(number: value))
                }
            }
        }.store(in: &bag)
    }

    private func createMap(from grid: SquareGrid ) {
        var x = 0
        var z = 0
        for row in grid.grid {
            var newRow = [SCNNode]()
            for col in row {

                let color = SceneKitMapDisplayService.colorForTile(number: col)
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

    static func colorForTile(number: UInt8) -> NSColor {
        switch number {
        case 0:
            return NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2)
        case 1:
            return NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.6)
        case 2:
            return NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.6)
        case 3:
            return NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.6)
        default:
            return NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.6)
        }
    }

    func updateTile(x: Int, z: Int, color: NSColor) {

        guard x > 0, z > 0, x < gridTiles.count, z < gridTiles.count,  let materials = gridTiles[z][x].geometry?.materials else {
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
