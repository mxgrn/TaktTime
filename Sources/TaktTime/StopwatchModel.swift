import Foundation
import SwiftUI

@MainActor
@Observable
final class StopwatchModel {
    private static let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TaktTime", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }()
    private static let secondsFile = dir.appendingPathComponent("seconds")
    private static let runningFile = dir.appendingPathComponent("running")

    var totalSeconds: Int = 0 {
        didSet {
            try? "\(totalSeconds)".write(to: Self.secondsFile, atomically: true, encoding: .utf8)
        }
    }
    var isRunning: Bool = false

    var hours: Int { totalSeconds / 3600 }
    var minutes: Int { (totalSeconds % 3600) / 60 }
    var seconds: Int { totalSeconds % 60 }

    var displayString: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var timer: Timer?

    init() {
        if let s = try? String(contentsOf: Self.secondsFile, encoding: .utf8), let n = Int(s) {
            totalSeconds = n
        }
        if let r = try? String(contentsOf: Self.runningFile, encoding: .utf8), r == "true" {
            start()
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.screensDidSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.isRunning else { return }
                self.timer?.invalidate()
                self.timer = nil
            }
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.isRunning, self.timer == nil else { return }
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        self?.totalSeconds += 1
                    }
                }
            }
        }
    }

    func toggleRunning() {
        if isRunning { stop() } else { start() }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        try? "true".write(to: Self.runningFile, atomically: true, encoding: .utf8)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.totalSeconds += 1
            }
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        try? "false".write(to: Self.runningFile, atomically: true, encoding: .utf8)
    }

    func reset() {
        stop()
        totalSeconds = 0
    }

    func adjust(by seconds: Int) {
        totalSeconds = max(0, totalSeconds + seconds)
    }
}
