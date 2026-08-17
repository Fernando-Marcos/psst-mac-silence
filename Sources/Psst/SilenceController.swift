import Foundation
import SwiftUI

@MainActor
final class SilenceController: ObservableObject {
    @Published var isActive: Bool
    @Published var isBusy = false
    @Published var statusMessage = "Silencia el Mac con un toque."
    @AppStorage("muteAudio") var muteAudio = true
    @AppStorage("runAutomation") var runAutomation = false

    private let activeKey = "silenceModeActive"
    private let snapshotURL: URL

    init() {
        isActive = UserDefaults.standard.bool(forKey: activeKey)
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Psst", isDirectory: true)
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        snapshotURL = support.appendingPathComponent("restore-state.json")
        if isActive { statusMessage = "El modo biblioteca sigue activo." }
    }

    func toggle() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        if isActive { deactivate() } else { activate() }
    }

    private func activate() {
        var warnings: [String] = []
        if muteAudio {
            do {
                let snapshot = try AudioService.capture()
                save(snapshot)
                try AudioService.silence()
            } catch { warnings.append(error.localizedDescription) }
        }
        if runAutomation && !AutomationService.run(active: true) {
            warnings.append("No se pudo abrir Atajos.")
        }
        isActive = true
        UserDefaults.standard.set(true, forKey: activeKey)
        statusMessage = warnings.isEmpty
            ? (runAutomation ? "Audio silenciado y automatización iniciada." : "Audio y avisos del sistema silenciados.")
            : warnings.joined(separator: " · ")
    }

    private func deactivate() {
        var warnings: [String] = []
        if let snapshot = load() {
            do { try AudioService.restore(snapshot) }
            catch { warnings.append(error.localizedDescription) }
        }
        if runAutomation && !AutomationService.run(active: false) {
            warnings.append("No se pudo abrir Atajos.")
        }
        isActive = false
        UserDefaults.standard.set(false, forKey: activeKey)
        try? FileManager.default.removeItem(at: snapshotURL)
        statusMessage = warnings.isEmpty ? "Ajustes de audio restaurados." : warnings.joined(separator: " · ")
    }

    private func save(_ snapshot: SilenceSnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) {
            try? data.write(to: snapshotURL, options: .atomic)
        }
    }

    private func load() -> SilenceSnapshot? {
        guard let data = try? Data(contentsOf: snapshotURL) else { return nil }
        return try? JSONDecoder().decode(SilenceSnapshot.self, from: data)
    }
}
