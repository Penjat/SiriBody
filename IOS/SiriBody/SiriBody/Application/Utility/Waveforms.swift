import Foundation

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
