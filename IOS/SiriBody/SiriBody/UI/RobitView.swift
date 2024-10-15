import SwiftUI
import Combine

struct RobitView: View {
    @EnvironmentObject var robitStateService: RealityKitService
    @EnvironmentObject var movementInteractor: MovementInteractor
    @EnvironmentObject var peripheralService: PeripheralService
    @EnvironmentObject var goalInteractor: GoalInteractor
    
    @StateObject var pidControl = PIDRotationControl()
    @StateObject var pidMotionControl = PIDMotionService()

    @State var motionEnabled = false
    @State var bag = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
        ScrollView {
            
                RealityKitStatusView()
                Spacer()
            switch goalInteractor.command {
            case .turnTo(let angle):
                Text("turn to: \(angle)")
            case .moveTo(let x, let z):
                Text("move to: \(x), \(z)")
            default:
                Text("no command")
            }
            HStack {
                
               
                
                Toggle(isOn: $pidMotionControl.motionEnabled) {
                    Text("motion")
                }
                Toggle(isOn: $pidMotionControl.rotationEnabled) {
                    Text("rotation")
                }
            }
                
            HStack {
                
               
                
                Button(action: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        goalInteractor.command = .moveTo(x: 0.0, z: 0.0)
                    }
                    
                }, label: {
                    Text("0,0")
                })
                
                
                Button(action: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        goalInteractor.command = .moveTo(x: 0.0, z: 3.0)
                    }
                    
                }, label: {
                    Text("0,3")
                })
                Button(action: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        goalInteractor.command = .moveTo(x: 0.6, z: 0.0)
                    }
                    
                }, label: {
                    Text("0.6,0.0")
                })
                
            }
                HStack {
                    Button(action: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goalInteractor.command = .turnTo(angle: 0.0)
                        }
                        
                    }, label: {
                        Text("north")
                    })
                    Button(action: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goalInteractor.command = .turnTo(angle: .pi/2)
                        }
                        
                    }, label: {
                        Text("east")
                    })
                    Button(action: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goalInteractor.command = .turnTo(angle: .pi)
                        }
                        
                    }, label: {
                        Text("south")
                    })
                    Button(action: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goalInteractor.command = .turnTo(angle: -(.pi/2))
                        }
                        
                    }, label: {
                        Text("west")
                    })
                    Button(action: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            goalInteractor.command = .turnTo(angle: Double.random(in: -Double.pi..<Double.pi))
                        }
                        
                    }, label: {
                        Text("rand")
                    })
                }
                
                Text("Yaw")
                
                Toggle(isOn: $motionEnabled) {
                    Text("Motion Enabled")
                }
                
                Spacer()
                Text("Max Speed: \(pidControl.maxSpeed)")
                Slider(value: $pidControl.maxSpeed, in: 50.0...254.0)
                
                Text("rotation:")
                HStack {
                    VStack {
                        
                        Toggle("", isOn: $pidControl.pIsOn)
                        Text("\(String(format: "%.2f", pidControl.pConstant))")
                        Text("\(String(format: "%.2f", pidControl.pOutput))").monospaced()
                        Slider(value: $pidControl.pConstant, in: 0.5...400).disabled(!pidControl.pIsOn)
                    }
                    
                    
                    VStack {
                        Toggle("", isOn: $pidControl.iIsOn)
                        Text("\(String(format: "%.2f", pidControl.iConstant))")
                        Text("\(String(format: "%.2f", pidControl.iOutput))").monospaced()
                        Slider(value: $pidControl.iConstant, in: 0.01...200).disabled(!pidControl.iIsOn)
                    }
                    
                    VStack {
                        Toggle("", isOn: $pidControl.dIsOn)
                        Text("\(String(format: "%.2f", pidControl.dConstant))")
                        Text("\(String(format: "%.2f", pidControl.dOutput))").monospaced()
                        Slider(value: $pidControl.dConstant, in: 0.5...200).disabled(!pidControl.dIsOn)
                    }
                    
                }.padding()
                .background(.regularMaterial).cornerRadius(8)
            Text("movement:")
            HStack {
                VStack {
                    Toggle("", isOn: $pidMotionControl.pDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kpDistance))")
//                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $pidMotionControl.kpDistance, in: 0.5...2000).disabled(!pidMotionControl.pDistanceIsOn)
                }
                
                VStack {
                    Toggle("", isOn: $pidMotionControl.iDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kiDistance))")
//                    Text("\(String(format: "%.2f", pidMotionControl.iOutput))").monospaced()
                    Slider(value: $pidMotionControl.kiDistance, in: 0.01...2000).disabled(!pidMotionControl.iDistanceIsOn)
                }
                
                VStack {
                    Toggle("", isOn: $pidMotionControl.dDistanceIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kdDistance))")
//                    Text("\(String(format: "%.2f", pidMotionControl.dOutput))").monospaced()
                    Slider(value: $pidMotionControl.kdDistance, in: 0.5...2000).disabled(!pidMotionControl.dDistanceIsOn)
                }
                
            }.padding()
            .background(.regularMaterial).cornerRadius(8)
            Text("movement+angle:")
            HStack {
                VStack {
                    Toggle("", isOn: $pidMotionControl.pAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kpAngle))")
//                    Text("\(String(format: "%.2f", pidMotionControl.pOutput))").monospaced()
                    Slider(value: $pidMotionControl.kpAngle, in: 0.5...200).disabled(!pidMotionControl.pAngleIsOn)
                }
                
                VStack {
                    Toggle("", isOn: $pidMotionControl.iAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kiAngle))")
//                    Text("\(String(format: "%.2f", pidMotionControl.iOutput))").monospaced()
                    Slider(value: $pidMotionControl.kiAngle, in: 0.01...200).disabled(!pidMotionControl.iAngleIsOn)
                }
                
                VStack {
                    Toggle("", isOn: $pidMotionControl.dAngleIsOn)
                    Text("\(String(format: "%.2f", pidMotionControl.kdAngle))")
//                    Text("\(String(format: "%.2f", pidMotionControl.dOutput))").monospaced()
                    Slider(value: $pidMotionControl.kdAngle, in: 0.5...200).disabled(!pidMotionControl.dAngleIsOn)
                }
                
            }.padding()
            .background(.regularMaterial).cornerRadius(8)
                
            }
            BluetoothStatusView()
            PeripheralStatusView()
        }.onAppear {
            robitStateService.$robitState.sink { state in
                // TODO: Eventually move this logic somewhere else
                guard let command = goalInteractor.command else {
                    return
                }
                switch command {
                case .turnTo(angle: let angle):
                    let turnVector = pidControl.motorOutput(currentYaw: Double(state?.deviceOrientation.z ?? 0.0))
                    print(turnVector)
                    
                    let forwardBackward = 0.0
                    let leftRight = max(-254,min(254,(turnVector)))
                    
                    let motor1Speed = max(-254,min(254,(forwardBackward - leftRight)))
                    let motor2Speed = max(-254,min(254,(forwardBackward + leftRight)))
                    
                    if motionEnabled {
                        movementInteractor.motorSpeed = (motor1Speed: Int(motor1Speed), motor2Speed: Int(motor2Speed))
                    }
                    
                
                case .moveTo(x: let x, z: let z):
                    if motionEnabled, let robitState = robitStateService.robitState {
                        movementInteractor.motorSpeed = pidMotionControl.motorSpeeds(robitState: robitState)
                    }
                    break
                }
                
            }.store(in: &bag)
            
            peripheralService.inputSubject.sink { data in
                print("recieved command! ")
                guard let command = Command.createFrom(data: data) else {
                    return
                }
                goalInteractor.command = command
            }.store(in: &bag)
            
            goalInteractor.$command.sink { command in
                print("command updated")
                switch command {
                case .moveTo(x: let x, z: let z):
                    pidMotionControl.target = (x: x, z: z)
                case .turnTo(angle: let angle):
                    pidControl.targetYaw = angle
                default:
                    return
                }
            }.store(in: &bag)
        }
    }
}

#Preview {
    RobitView()
}
