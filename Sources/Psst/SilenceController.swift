import Foundation
import SwiftUI

@MainActor
final class SilenceController: ObservableObject {
    @Published var isActive: Bool
    @Published var isBusy = false
    @Published var statusMessage = "Silencia el Mac con un solo toque."
    @Published var focusAutomationAvailable = FocusService.isAvailable()
    @AppStorage("muteAudio") var muteAudio = true
    @AppStorage("reduceHeat") var reduceHeat = true

    private let activeKey = "silenceModeActive"
    private let snapshotURL: URL

    init() {
        isActive = UserDefaults.standard.bool(forKey: activeKey)
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Psst", isDirectory: true)
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        snapshotURL = support.appendingPathComponent("restore-state.json")
        if isActive {
            statusMessage = "Los ajustes siguen activos desde la última sesión."
        }
    }

    func toggle() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        if isActive {
            await deactivate()
        } else {
            await activate()
        }
    }

    private func activate() async {
        var warnings: [String] = []
        let audioSnapshot = muteAudio ? try? AudioService.capture() : nil
        let powerSnapshot = reduceHeat ? try? PowerService.capture() : nil
        save(SilenceSnapshot(audio: audioSnapshot, power: powerSnapshot))

        if muteAudio {
            do { try AudioService.silence() }
            catch { warnings.append("audio: \(error.localizedDescription)") }
        }
        if reduceHeat {
            do { try PowerService.reduceHeat() }
            catch { warnings.append("energía: \(clean(error.localizedDescription))") }
        }

        focusAutomationAvailable = FocusService.isAvailable()
        if focusAutomationAvailable {
            do { try FocusService.activate() }
            catch { warnings.append("Concentración: \(clean(error.localizedDescription))") }
        }

        isActive = true
        UserDefaults.standard.set(true, forKey: activeKey)
        statusMessage = warnings.isEmpty
            ? (focusAutomationAvailable ? "Audio, concentración y consumo reducidos." : "Audio y consumo reducidos. Configura Concentración para bloquear notificaciones.")
            : "Activo con aviso: \(warnings.joined(separator: " · "))"
    }

    private func deactivate() async {
        var warnings: [String] = []
        let snapshot = load()

        if let audio = snapshot?.audio {
            do { try AudioService.restore(audio) }
            catch { warnings.append("audio: \(error.localizedDescription)") }
        }
        if let power = snapshot?.power {
            do { try PowerService.restore(power) }
            catch { warnings.append("energía: \(clean(error.localizedDescription))") }
        }
        if FocusService.isAvailable() {
            do { try FocusService.deactivate() }
            catch { warnings.append("Concentración: \(clean(error.localizedDescription))") }
        }

        isActive = false
        UserDefaults.standard.set(false, forKey: activeKey)
        try? FileManager.default.removeItem(at: snapshotURL)
        statusMessage = warnings.isEmpty ? "Ajustes anteriores restaurados." : "Desactivado con aviso: \(warnings.joined(separator: " · "))"
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

    private func clean(_ message: String) -> String {
        message.replacingOccurrences(of: "execution error: ", with: "")
    }
}
