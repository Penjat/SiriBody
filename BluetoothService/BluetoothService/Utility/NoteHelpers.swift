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

    static func pitchInfo(inputLowerBound: Double, inputUpperBound: Double, outputLowerBound: Int, outputUpperBound: Int, inputValue: Double) -> PitchInfo? {
        let inputValue = min(max(inputLowerBound, inputValue), inputUpperBound)

        let mappedValue = mapValue(inputValue, inputLowerBound, inputUpperBound, Double(outputLowerBound), Double(outputUpperBound))

        let noteNumber = Int(round(mappedValue))

        let a = 1.059463094359
        let referenceFrequency = 440.0 // A4
        let exactFrequency = referenceFrequency * pow(a, mappedValue - 69)

        if let noteInfo = noteInfo(for: noteNumber) {
            let pitchInfo = PitchInfo(
                noteNumber: noteNumber,
                noteName: noteInfo.noteName,
                pitch: noteInfo.pitch,
                frequencySnapped: noteInfo.frequency,
                frequencyExact: exactFrequency
            )
            return pitchInfo
        }

        return nil // Invalid MIDI note number
    }

    static func mapValue(_ value: Double, _ inputMin: Double, _ inputMax: Double, _ outputMin: Double, _ outputMax: Double) -> Double {
            // Clamp the value to the input range
            let clampedValue = min(max(value, inputMin), inputMax)
            return (clampedValue - inputMin) * (outputMax - outputMin) / (inputMax - inputMin) + outputMin
        }
}
