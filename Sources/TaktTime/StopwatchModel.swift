import Foundation
import SwiftUI

@MainActor
@Observable
final class StopwatchModel {
    var totalSeconds: Int = 0
    var isRunning: Bool = false

    var hours: Int { totalSeconds / 3600 }
    var minutes: Int { (totalSeconds % 3600) / 60 }
    var seconds: Int { totalSeconds % 60 }

    var displayString: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private var timer: Timer?

    func toggleRunning() {
        if isRunning { stop() } else { start() }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
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
    }

    func reset() {
        stop()
        totalSeconds = 0
    }

    func adjust(by seconds: Int) {
        totalSeconds = max(0, totalSeconds + seconds)
    }
}
