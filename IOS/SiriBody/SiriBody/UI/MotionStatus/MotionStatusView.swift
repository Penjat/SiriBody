import SwiftUI

struct MotionStatusView: View {
    @EnvironmentObject var motionService: MotionService
    var body: some View {
        VStack {
            Text("pitch: \(motionService.position?.attitude.pitch)")
            Text("yaw: \(motionService.position?.attitude.yaw)")
            Text("roll:\(motionService.position?.attitude.roll)")
            Text("\(motionService.acceleration?.acceleration.x)")
            Text("\(motionService.acceleration?.acceleration.y)")
            Text("\(motionService.acceleration?.acceleration.z)")
        }
    }
}
