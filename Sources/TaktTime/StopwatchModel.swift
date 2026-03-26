import Foundation
import SwiftUI

@MainActor
@Observable
final class StopwatchModel {
    private static let totalSecondsKey = "totalSeconds"
    private static let isRunningKey = "isRunning"
    private static let lastTickKey = "lastTickDate"

    var totalSeconds: Int = 0 {
        didSet { save() }
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
        let defaults = UserDefaults.standard
        let saved = defaults.integer(forKey: Self.totalSecondsKey)
        let wasRunning = defaults.bool(forKey: Self.isRunningKey)

        if wasRunning, let lastTick = defaults.object(forKey: Self.lastTickKey) as? Date {
            let elapsed = Int(Date().timeIntervalSince(lastTick))
            totalSeconds = saved + max(0, elapsed)
            start()
        } else {
            totalSeconds = saved
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.save()
            }
        }
    }

    func toggleRunning() {
        if isRunning { stop() } else { start() }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        save()
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
        save()
    }

    func reset() {
        stop()
        totalSeconds = 0
    }

    func adjust(by seconds: Int) {
        totalSeconds = max(0, totalSeconds + seconds)
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(totalSeconds, forKey: Self.totalSecondsKey)
        defaults.set(isRunning, forKey: Self.isRunningKey)
        if isRunning {
            defaults.set(Date(), forKey: Self.lastTickKey)
        } else {
            defaults.removeObject(forKey: Self.lastTickKey)
        }
    }
}
