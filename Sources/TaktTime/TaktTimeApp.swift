import SwiftUI

@main
struct TaktTimeApp: App {
    init() {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate()
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    var body: some Scene {
        Window("TaktTime", id: "main") {
            StopwatchView()
        }
        .windowResizability(.contentSize)
    }
}
