//
//  ShazamRecognizer.swift
//  P01-Shazam
//
//  Created by Cédric Bahirwe on 03/11/2022.
//

import SwiftUI
import ShazamKit

final class ShazamRecognizer: NSObject, ObservableObject {
    private let shazamSession = SHSession()

    private let audioEngine = AVAudioEngine()

    @Published var error: ErrorAlert? = nil

    @Published private(set) var isRecording = false

    @Published private(set) var matchedTrack: ShazamTrack?

    override init() {
        super.init()
        shazamSession.delegate = self
    }
}

extension ShazamRecognizer: SHSessionDelegate {
    func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async {
            if let firstItem = match.mediaItems.first {
                print(ShazamTrack(firstItem))
                self.matchedTrack = ShazamTrack(firstItem)
                self.stopAudioRecording()
            }
        }
    }

    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.error = ErrorAlert(error?.localizedDescription ?? "No Match found!")
            self.stopAudioRecording()
        }
    }
}

// MARK: Fetch music
extension ShazamRecognizer {
    func listenToMusic() {
        let audioSessioin = AVAudioSession.sharedInstance()

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
        if audioEngine.isRunning {
            self.stopAudioRecording()
            return
        } 

        let inputNode = audioEngine.inputNode

        let format = inputNode.outputFormat(forBus: .zero)

        inputNode.removeTap(onBus: .zero)

        inputNode.installTap(onBus: .zero,
                             bufferSize: 1024,
                             format: format)
        { buffer, time in
            self.shazamSession.matchStreamingBuffer(buffer, at: time )
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
