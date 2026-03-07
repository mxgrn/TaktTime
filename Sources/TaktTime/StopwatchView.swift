import SwiftUI

struct StopwatchView: View {
    @State private var model = StopwatchModel()

    private let presets: [(label: String, seconds: Int)] = [
        ("1h", 3600), ("30m", 1800), ("15m", 900), ("5m", 300)
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text(model.displayString)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .contentTransition(.numericText())

            HStack(spacing: 16) {
                Button(model.isRunning ? "Stop" : "Start") {
                    model.toggleRunning()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    model.reset()
                }
                .disabled(model.isRunning || model.totalSeconds == 0)
            }

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.seconds) { preset in
                        Button("+\(preset.label)") {
                            model.adjust(by: preset.seconds)
                        }
                    }
                }
                HStack(spacing: 8) {
                    ForEach(presets, id: \.seconds) { preset in
                        Button("-\(preset.label)") {
                            model.adjust(by: -preset.seconds)
                        }
                        .disabled(model.totalSeconds < preset.seconds)
                    }
                }
            }
        }
        .padding(24)
        .frame(width: 320)
    }
}
