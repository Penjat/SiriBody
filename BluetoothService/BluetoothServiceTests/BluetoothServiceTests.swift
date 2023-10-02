//
//  BluetoothServiceTests.swift
//  BluetoothServiceTests
//
//  Created by Spencer Symington on 2023-10-01.
//

import XCTest

//@testable import NoteHelpers
class NoteInfoTests: XCTestCase {

    func testNoteInfo() {
        let validNoteNumbers: [Int] = [60, 64, 69, 72, 76, 81]

        for noteNumber in validNoteNumbers {
            // Test valid MIDI note numbers
            let noteInfo = Note.noteInfo(for: noteNumber)
            XCTAssertNotNil(noteInfo)

            switch noteNumber {
            case 60:
                XCTAssertEqual(noteInfo?.noteName, "C")
                XCTAssertEqual(noteInfo?.pitch, "C4")
                XCTAssertEqual(noteInfo!.frequency, 261.63, accuracy: 0.01)
            case 64:
                XCTAssertEqual(noteInfo?.noteName, "E")
                XCTAssertEqual(noteInfo?.pitch, "E4")
                XCTAssertEqual(noteInfo!.frequency, 329.63, accuracy: 0.01)
            case 69:
                XCTAssertEqual(noteInfo?.noteName, "A")
                XCTAssertEqual(noteInfo?.pitch, "A4")
                XCTAssertEqual(noteInfo!.frequency, 440.0, accuracy: 0.01)
            case 72:
                XCTAssertEqual(noteInfo?.noteName, "C")
                XCTAssertEqual(noteInfo?.pitch, "C5")
                XCTAssertEqual(noteInfo!.frequency, 523.25, accuracy: 0.01)
            case 76:
                XCTAssertEqual(noteInfo?.noteName, "E")
                XCTAssertEqual(noteInfo?.pitch, "E5")
                XCTAssertEqual(noteInfo!.frequency, 659.26, accuracy: 0.01)
            case 81:
                XCTAssertEqual(noteInfo?.noteName, "A")
                XCTAssertEqual(noteInfo?.pitch, "A5")
                XCTAssertEqual(noteInfo!.frequency, 880.0, accuracy: 0.01)
            default:
                XCTFail("Unexpected note number")
            }
        }

        // Test invalid MIDI note number (-1)
        let invalidNoteInfo = Note.noteInfo(for: -1)
        XCTAssertNil(invalidNoteInfo)
    }

    func testPitchInfoWithinBounds() {
        // Test a value within bounds (inputValue = 0.5)
        let result = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 69, outputUpperBound: 81, inputValue: 0.0)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.noteName, "A")
        XCTAssertEqual(result?.pitch, "A4")
        XCTAssertEqual(result!.frequencySnapped, 440.0, accuracy: 0.01)
        XCTAssertEqual(result!.frequencyExact, 440.0, accuracy: 0.01)

        let result2 = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 69, outputUpperBound: 81, inputValue: 1.0)
        XCTAssertNotNil(result2)
        XCTAssertEqual(result2?.noteName, "A")
        XCTAssertEqual(result2?.pitch, "A5")
        XCTAssertEqual(result2!.frequencySnapped, 880.0, accuracy: 0.01)
        XCTAssertEqual(result2!.frequencyExact, 880.0, accuracy: 0.01)
    }

    func testPitchInfoWithinBounds2() {
        // Test a value within bounds (inputValue = 0.5)
        let result = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 69, outputUpperBound: 79, inputValue: 0.2)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.noteName, "B")
        XCTAssertEqual(result?.pitch, "B4")
        XCTAssertEqual(result!.frequencySnapped, 493.88, accuracy: 0.01)
        XCTAssertEqual(result!.frequencyExact, 493.88, accuracy: 0.01)

        let result2 = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 69, outputUpperBound: 81, inputValue: 0.54)
        XCTAssertNotNil(result)
        XCTAssertEqual(result2?.noteName, "D#")
        XCTAssertEqual(result2?.pitch, "D#5")
        XCTAssertEqual(result2!.frequencySnapped, 622.25, accuracy: 0.01)
        XCTAssertEqual(result2!.frequencyExact, 639.74, accuracy: 0.01)
    }

    func testPitchInfoOutsideBounds() {
        // Test a value outside bounds (inputValue = -1.0)
        let result = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 60, outputUpperBound: 72, inputValue: -1.0)
        XCTAssertNil(result)
    }

    func testPitchInfoInvalidNoteNumber() {
        // Test an invalid MIDI note number
        let result = Note.pitchInfo(inputLowerBound: 0.0, inputUpperBound: 1.0, outputLowerBound: 0, outputUpperBound: 10, inputValue: -0.7)
        XCTAssertNil(result)
    }

}

