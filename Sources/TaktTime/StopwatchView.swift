import SwiftUI

struct StopwatchView: View {
    @State private var model = StopwatchModel()
    @State private var dotBright = false
    @State private var showResetConfirmation = false

    private let presets: [(label: String, seconds: Int)] = [
        ("1h", 3600), ("30m", 1800), ("15m", 900), ("5m", 300)
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Circle()
                    .fill(dotBright ? Color(red: 0.0, green: 1.0, blue: 0.0) : .green)
                    .shadow(color: dotBright ? .green : .clear, radius: 6)
                    .frame(width: 12, height: 12)
                    .opacity(model.isRunning ? (dotBright ? 1 : 0.3) : 0)
                    .animation(.easeOut(duration: 0.5), value: dotBright)
                    .onChange(of: model.totalSeconds) {
                        dotBright = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dotBright = false
                        }
                    }

                Text(model.displayString)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .contentTransition(.numericText())
            }

            HStack(spacing: 16) {
                Button(model.isRunning ? "Stop" : "Start") {
                    model.toggleRunning()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    showResetConfirmation = true
                }
                .keyboardShortcut("r", modifiers: [])
                .disabled(model.isRunning || model.totalSeconds == 0)
                .alert("Reset the stopwatch?", isPresented: $showResetConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Reset", role: .destructive) {
                        model.reset()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    ForEach(presets, id: \.seconds) { preset in
                        Button("+\(preset.label)") {
                            model.adjust(by: preset.seconds)
                        }
                    }
                }
                GridRow {
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
