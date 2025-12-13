//
//  RecordingService.swift
//  MySound
//
//  Created by apple on 12/11/25.
//

import Foundation
import AVFoundation
import Combine
import os

final class RecordingService: NSObject, ObservableObject {
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var currentLevel: Float = 0.0 // 0.0 ... 1.0 normalized
    
    private var recorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private let logger = Logger(subsystem: "com.yourcompany.MySound", category: "RecordingService")
    
    // Last recorded file URL (temporary)
    @Published private(set) var fileURL: URL?
    
    func startRecording(fileName: String = "recording-\(UUID().uuidString).m4a") {
        requestPermissionIfNeeded { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.logger.error("Microphone permission not granted.")
                return
            }
            do {
                try self.configureAudioSession()
                let url = self.makeTempURL(fileName: fileName)
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                self.recorder = try AVAudioRecorder(url: url, settings: settings)
                self.recorder?.isMeteringEnabled = true
                self.recorder?.delegate = self
                if self.recorder?.record() == true {
                    DispatchQueue.main.async {
                        self.fileURL = url
                        self.isRecording = true
                    }
                    self.startMetering()
                } else {
                    self.logger.error("Failed to start recording.")
                }
            } catch {
                self.logger.error("Recording setup failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
        stopMetering()
        deactivateAudioSession()
        DispatchQueue.main.async {
            self.isRecording = false
            self.currentLevel = 0.0
        }
    }
    
    // MARK: - Permission
    private func requestPermissionIfNeeded(_ completion: @escaping (Bool) -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Audio Session
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [])
        } catch {
            logger.warning("Failed to deactivate audio session: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    // MARK: - Metering
    private func startMetering() {
        stopMetering()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateMeters()
        }
        RunLoop.current.add(levelTimer!, forMode: .common)
    }
    
    private func stopMetering() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    private func updateMeters() {
        guard let recorder = recorder, recorder.isRecording else { return }
        recorder.updateMeters()
        // averagePower ranges roughly from -160 (silence) to 0 dB
        let avg = recorder.averagePower(forChannel: 0)
        let normalized = Self.normalize(power: avg)
        DispatchQueue.main.async { [weak self] in
            self?.currentLevel = normalized
        }
    }
    
    private static func normalize(power: Float) -> Float {
        // Map -60...0 dB to 0...1, clamp below -60 to 0
        let minDb: Float = -60.0
        if power < minDb { return 0.0 }
        let level = (power - minDb) / -minDb
        return max(0.0, min(level, 1.0))
    }
    
    // MARK: - Helpers
    private func makeTempURL(fileName: String) -> URL {
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(fileName)
    }
}

extension RecordingService: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        logger.error("Encoding error: \(error?.localizedDescription ?? "unknown", privacy: .public)")
    }
}

