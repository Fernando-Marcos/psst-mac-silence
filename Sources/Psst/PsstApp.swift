import SwiftUI

@main
struct PsstApp: App {
    @StateObject private var silence = SilenceController()

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(silence)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 468, height: 468)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("Acerca de Psst") {
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .applicationName: "Psst",
                        .applicationVersion: "1.1.0",
                        .credits: NSAttributedString(
                            string: "Silencio seguro para estudiar y trabajar sin molestar.",
                            attributes: [.foregroundColor: NSColor.secondaryLabelColor]
                        )
                    ])
                }
            }
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(silence)
        } label: {
            Label("Psst", systemImage: silence.isActive ? "speaker.slash.fill" : "speaker.wave.1")
        }
    }
}
