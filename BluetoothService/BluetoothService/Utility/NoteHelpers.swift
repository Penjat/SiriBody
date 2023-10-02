import Foundation

enum Note {

    static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    static func noteInfo(for noteNumber: Int) -> (noteName: String, pitch: String, frequency: Double)? {
        guard (0...127).contains(noteNumber) else {
            return nil // Invalid note number
        }


        let octave = (noteNumber / 12) - 1
        let noteIndex = noteNumber % 12

        let noteName = noteNames[noteIndex]
        let pitch = "\(noteName)\(octave)"

        let a = 1.059463094359
        let frequency = 440.0 * pow(a, Double(noteNumber - 69))

        return (noteName, pitch, frequency)
    }

    static func pitchInfo(inputLowerBound: Double, inputUpperBound: Double, outputLowerBound: Int, outputUpperBound: Int, inputValue: Double) -> (noteName: String, pitch: String, frequencySnapped: Double, frequencyExact: Double)? {
        // Ensure that the input value is within the specified input bounds
        guard inputValue >= inputLowerBound && inputValue <= inputUpperBound else {
            return nil
        }

        // Map the inputValue from the input range to the output range
        let mappedValue = mapValue(inputValue, inputLowerBound, inputUpperBound, Double(outputLowerBound), Double(outputUpperBound))

        // Calculate MIDI note number for the mapped value
        let noteNumber = Int(round(mappedValue))

        // Calculate the exact frequency based on the mapped value
//        let a = pow(2.0, 1.0 / 12.0) // The 12th root of 2
        let a = 1.059463094359
        let referenceFrequency = 440.0 // A4
        let exactFrequency = referenceFrequency * pow(a, mappedValue - 69)

        // Get note information using the noteInfo function
        if let noteInfo = noteInfo(for: noteNumber) {
            return (noteInfo.noteName, noteInfo.pitch, noteInfo.frequency, exactFrequency)
        }

        return nil // Invalid MIDI note number
    }

    static func mapValue(_ value: Double, _ inputMin: Double, _ inputMax: Double, _ outputMin: Double, _ outputMax: Double) -> Double {
            // Clamp the value to the input range
            let clampedValue = min(max(value, inputMin), inputMax)
            return (clampedValue - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin
        }
}
