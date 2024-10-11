//import SwiftUI
//import RealityKit
//import ARKit
//import Combine
//
//struct RobitRealityView : View {
//    @EnvironmentObject var realityKitService: RealityKitService
//    var body: some View {
//        VStack {
//            
//            Text("Position: x: \(realityKitService.devicePosition.x), y: \(realityKitService.devicePosition.y), z: \(realityKitService.devicePosition.z)")
//            Text("Orientation: pitch: \(realityKitService.deviceOrientation.x), yaw: \(realityKitService.deviceOrientation.y), roll: \(realityKitService.deviceOrientation.z)")
//                            .padding()
//            MyARViewContainer(realityKitService: realityKitService, devicePosition: $realityKitService.devicePosition, deviceOrientation: $realityKitService.deviceOrientation)
//            .edgesIgnoringSafeArea(.all)
//        }
//        
////        .navigationBarItems(leading: Button(action: {viewModel.showMenu = true}, label: {
////            Text("menu")
////        }), trailing: Button("swap", action: {
//////            viewModel.toggleSquare()
////        }))
//        .onAppear {
//            
//        }
////        .sheet(isPresented: $viewModel.showMenu) {
////            
////        }
//    }
//}
//
//struct MyARViewContainer: UIViewRepresentable {
//    let realityKitService: RealityKitService
//    @Binding var devicePosition: SIMD3<Float>
//    @Binding var deviceOrientation: SIMD3<Float>
//    
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero, cameraMode: .ar,  automaticallyConfigureSession: true)
//        realityKitService.setARView(arView)
//        
//        arView.environment.background = .color(.gray)
//        let pointLight = PointLight()
//        pointLight.light.intensity = 10000
//        
//        let lightAnchor = AnchorEntity(world: [0,0,0])
//        lightAnchor.addChild(pointLight)
//        arView.scene.addAnchor(lightAnchor)
//        
//        let configuration = ARWorldTrackingConfiguration()
//                configuration.planeDetection = [.horizontal]
//                arView.session.run(configuration)
//                
//                // Add an ARSession delegate to track the device position
//                arView.session.delegate = context.coordinator
//        return arView
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//            return Coordinator(devicePosition: $devicePosition, deviceOrientation: $deviceOrientation)
//        }
//        
//        class Coordinator: NSObject, ARSessionDelegate {
//            @Binding var devicePosition: SIMD3<Float>
//            @Binding var deviceOrientation: SIMD3<Float>
//            
//            init(devicePosition: Binding<SIMD3<Float>>, deviceOrientation: Binding<SIMD3<Float>>) {
//                _devicePosition = devicePosition
//                _deviceOrientation = deviceOrientation
//            }
//            
//            func session(_ session: ARSession, didUpdate frame: ARFrame) {
//                let transform = frame.camera.transform
//                
//                // Extract position
//                let position = transform.columns.3
//                devicePosition = SIMD3(position.x, position.y, position.z)
//                
//                // Extract orientation (angle)
//                let column0 = transform.columns.0
//                let column1 = transform.columns.1
//                let column2 = transform.columns.2
//                
//                let yaw = atan2(column0.y, column0.x)
//                let pitch = atan2(-column0.z, sqrt(pow(column1.z, 2) + pow(column2.z, 2)))
//                let roll = atan2(column1.z, column2.z)
//                
//                deviceOrientation = SIMD3(pitch, yaw, roll)
//            }
//        }
//}
