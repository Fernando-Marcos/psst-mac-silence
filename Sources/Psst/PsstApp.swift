import SwiftUI

@main
struct PsstApp: App {
    @StateObject private var silence = SilenceController()

    /// Read from Info.plist so the About panel can never drift from the bundle version again.
    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

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
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center

                    let credits = NSMutableAttributedString(
                        string: "Silencio para concentrarte.\nRespeto para no molestar.\n\n© 2026 ",
                        attributes: [
                            .foregroundColor: NSColor.secondaryLabelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    )
                    credits.append(NSAttributedString(
                        string: "Fernando Marcos",
                        attributes: [
                            .foregroundColor: NSColor.linkColor,
                            .link: URL(string: "https://fernandomarcos.com")!,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))

                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .applicationName: "Psst",
                        .applicationVersion: Self.appVersion,
                        .credits: credits,
                        NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): ""
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
