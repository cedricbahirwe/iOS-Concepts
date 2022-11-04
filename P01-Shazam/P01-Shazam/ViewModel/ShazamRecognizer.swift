//
//  ShazamRecognizer.swift
//  P01-Shazam
//
//  Created by Cédric Bahirwe on 03/11/2022.
//

import SwiftUI
import ShazamKit

final class ShazamRecognizer: NSObject, ObservableObject {
    // Shazam Engine
    @Published private(set) var session = SHSession()

    // Audio Engine
    @Published private(set) var audioEngine = AVAudioEngine()

    @Published private(set) var isRecording = false

    @Published private(set) var matchedTrack: ShazamTrack?

    @Published var error: ErrorAlert? = nil

    override init() {
        super.init()
        // Sets delegate
        session.delegate = self
    }
}

extension ShazamRecognizer: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        // Match found
        DispatchQueue.main.async {
            if let firstItem = match.mediaItems.first {
                self.matchedTrack = ShazamTrack(firstItem)
                self.stopAudioRecording()
            }
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        // No match found
        DispatchQueue.main.async {
            self.error = ErrorAlert(error?.localizedDescription ?? "No Match found!")
            // Stop Audio recording
            self.stopAudioRecording()
        }
    }
}

// MARK: Fetch music
extension ShazamRecognizer {
    func listenToMusic() {
        let audioSessioin = AVAudioSession.sharedInstance()

        // Check for record permission
        audioSessioin.requestRecordPermission { status in
            if status {
                self.recordAudio()
            } else {
                self.error = ErrorAlert("Please Allow Microphone Access !!!")
            }
        }
    }

    func reset() {
        matchedTrack = nil
        stopAudioRecording()
    }

    private func recordAudio() {
        // Check if recording already then stop it
        if audioEngine.isRunning {
            self.stopAudioRecording()
            return
        } 

        // Create node and listen to it
        let inputNode = audioEngine.inputNode
        // Format
        let format = inputNode.outputFormat(forBus: .zero)

        // removing tap if already installed
        inputNode.removeTap(onBus: .zero)

        // Install tap
        inputNode.installTap(onBus: .zero,
                             bufferSize: 1024,
                             format: format)
        { buffer, time in
            // Will listen to music continiously
            // Start Shazam Session
            self.session.matchStreamingBuffer(buffer, at: time )
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()

            DispatchQueue.main.async {
                withAnimation {
                    self.isRecording = true
                }
            }
        } catch {
            self.error = ErrorAlert(error.localizedDescription)
        }
    }

    private func stopAudioRecording() {
        audioEngine.stop()
        withAnimation {
            isRecording = false
        }
    }
}
