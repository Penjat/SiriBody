func triangleWave(_ input: Double) -> Double {
    return (abs((input + Double.pi/2).remainder(dividingBy:Double.pi*2)/Double.pi)-0.5)*2
}

func squareWave(_ input: Double) -> Double  {
    return (input.remainder(dividingBy: Double.pi*2) >= 0) ? 1 : -1
}

func sawWave(_ input: Double) -> Double {
    return (input).truncatingRemainder(dividingBy: Double.pi*2)/(Double.pi)-1
}

func whiteNoise(_ input: Double) -> Double {
    return Double.random(in: -1...1)
}

func pinkNoise(_ input: Double) -> Double {
    // Number of random generators to sum
    let numGenerators = 16

    // Static variables to maintain state between function calls
    struct Static {
        static var generators = [Double](repeating: 0.0, count: 16)
        static var runningSum: Double = 0.0
        static var index: UInt = 0
    }

    // Update the index
    Static.index += 1

    // Determine which generators to update based on the index
    var n = Static.index
    var lastUpdatedGenerator = -1
    for i in 0..<numGenerators {
        if n & 1 == 1 {
            lastUpdatedGenerator = i
            break
        }
        n >>= 1
    }

    if lastUpdatedGenerator >= 0 {
        // Subtract the old value of the generator from the running sum
        Static.runningSum -= Static.generators[lastUpdatedGenerator]
        // Generate a new random value for this generator
        Static.generators[lastUpdatedGenerator] = Double.random(in: -1.0...1.0) / Double(numGenerators)
        // Add the new value to the running sum
        Static.runningSum += Static.generators[lastUpdatedGenerator]
    }

    // The output is the running sum of the generators
    return Static.runningSum
}


for i in 0..<100 {
    let time = Double(i) * 0.01
    let value = pinkNoise(time)
    print(value)
}


import SwiftUI
import PlaygroundSupport


struct WaveView: View {
    var title: String = ""
    let frequency: Double
    var wav: (Double) -> Double = sin
    var color: Color
    var magnitude = 1.0
    var body: some View {
        VStack {
            Text(title)
            HStack(spacing: 0) {
                ForEach(0..<500){ index in
                    let wavOutput = (wav(Double(index)/500.0*Double.pi*2*frequency)/magnitude)/2
                    let height = wavOutput*30

                    VStack(spacing: 0.0) {
                        VStack(spacing: 1.0) {
                            Spacer()
                            Rectangle().fill(color).frame(width: 4, height: max(0, height))
                        }
                        VStack {
                            Rectangle().fill(.purple).frame(width: 4, height: max(0,-height))
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    let wav: (Double) -> Double =  { input in
        return pinkNoise(input)*4 + sin(input + 0.4)
    }
    var body: some View {


        WaveView(frequency: 1, wav: wav, color: .blue, magnitude: 0.2)
            .font(.largeTitle)
            .padding()
            .frame(height: 800)
    }
}

PlaygroundPage.current.setLiveView(ContentView())







