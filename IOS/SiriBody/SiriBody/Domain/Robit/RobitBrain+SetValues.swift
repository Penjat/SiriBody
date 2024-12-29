import Foundation


extension RobitBrain {
    func updateSetting(data: Data) {
        print("recived a set value cmd")
        
        switch TransferCode.init(rawValue: data[0]) {
        
        case .setRotationP:
            if let value = TransferService.dataToDouble(data.dropFirst()) {
                self.motionController.rotationController.pConstant = value
            }
            
        case .setRotationI:
            break
        case .setRotationD:
            break
        case .setRotationMax:
            break
        case .setTranslationP:
            break
        case .setTranslationI:
            break
        case .setTranslationD:
            break
        case .setTranslationMax:
            break
        default:
            break
        }
    }
    
    
}
