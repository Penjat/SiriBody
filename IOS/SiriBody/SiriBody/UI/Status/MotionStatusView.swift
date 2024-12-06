import SwiftUI

struct MotionStatusView: View {
//    @EnvironmentObject var motionService: MotionService
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                VStack {
//                    Text("goal: \(String(format: "%.2f", goalInteractor.targetYaw))")
//                    Text("Yaw")
//                    ZStack {
//                        // Original Orange Circle
//                        Circle()
//                            .trim(from: 0, to: CGFloat(((goalInteractor.targetYaw) + .pi) / (2 * .pi)))
//                            .stroke(Color.orange, lineWidth: 20)
//                            .frame(width: 80, height: 80)
//                            .rotationEffect(.degrees(-90))
//                        
//                        // New Circle - goes opposite of Orange
//                        Circle()
//                            .trim(from: CGFloat(((goalInteractor.targetYaw) + .pi) / (2 * .pi)), to: 1)
//                            .stroke(Color.blue, lineWidth: 20)
//                            .frame(width: 80, height: 80)
//                            .rotationEffect(.degrees(-90))
//
//                        // Original Green Circle
//                        Circle()
//                            .trim(from: 0, to: CGFloat(((motionService.position?.attitude.yaw ?? 0) + .pi) / (2 * .pi)))
//                            .stroke(Color.green, lineWidth: 10)
//                            .frame(width: 80, height: 80)
//                            .rotationEffect(.degrees(-90))
//                            .overlay(Text("\(String(format: "%.2f", motionService.position?.attitude.yaw ?? 0.0))"))
//
//                        
//
//                        // New Circle - goes opposite of Green
//                        Circle()
//                            .trim(from: CGFloat(((motionService.position?.attitude.yaw ?? 0) + .pi) / (2 * .pi)), to: 1)
//                            .stroke(Color.purple, lineWidth: 10)
//                            .frame(width: 80, height: 80)
//                            .rotationEffect(.degrees(-90))
//                    }
//                    
//                    Text(approximatelyEqual(goalInteractor.targetYaw, motionService.position?.attitude.yaw ?? 0, tolerance: 0.025) ? "matches" : "doesn't match")
//                }
                
                
                //                        VStack {
                //                            Text("Roll")
                //                            Circle()
                //                                .trim(from: 0, to: CGFloat(((motionService.position?.attitude.roll ?? 0) + .pi) / (2 * .pi)))
                //                                .stroke(Color.red, lineWidth: 10)
                //                                .frame(width: 80, height: 80)
                //                                .rotationEffect(.degrees(-90))
                //                                .overlay(Text("\(String(format: "%.2f", motionService.position?.attitude.roll ?? 0.0))"))
                //                        }
            }
            
            //                    HStack(spacing: 20) {
            //                        VStack {
            //                            Text("X")
            //                            Capsule()
            //                                .fill(Color.purple)
            //                                .frame(width: 30, height: CGFloat(abs(motionService.acceleration?.acceleration.x ?? 0.0) * 100))
            //                                .overlay(Text("\(String(format: "%.2f", motionService.acceleration?.acceleration.x ?? 0.0))").offset(y: 40))
            //                        }
            //
            //                        VStack {
            //                            Text("Y")
            //                            Capsule()
            //                                .fill(Color.orange)
            //                                .frame(width: 30, height: CGFloat(abs(motionService.acceleration?.acceleration.y ?? 0.0) * 100))
            //                                .overlay(Text("\(String(format: "%.2f", motionService.acceleration?.acceleration.y ?? 0.0))").offset(y: 40))
            //                        }
            //
            //                        VStack {
            //                            Text("Z")
            //                            Capsule()
            //                                .fill(Color.cyan)
            //                                .frame(width: 30, height: CGFloat(abs(motionService.acceleration?.acceleration.z ?? 0.0) * 100))
            //                                .overlay(Text("\(String(format: "%.2f", motionService.acceleration?.acceleration.z ?? 0.0))").offset(y: 40))
            //                        }
            //                    }
            
//            Button {
//                goalInteractor.targetYaw = Double.random(in: -Double.pi..<Double.pi)
//            } label: {
//                Text("new goal")
            }
            
        }
        .padding()
    }
}
