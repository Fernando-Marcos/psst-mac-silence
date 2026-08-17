import AppKit
import Foundation
import SwiftUI

@MainActor
final class SilenceController: ObservableObject {
    @Published var isActive: Bool
    @Published var isBusy = false
    @Published var isShowingBlockedNotice = false
    @Published var statusMessage = "Silencia el Mac con un toque."
    @AppStorage("runAutomation") var runAutomation = false
    @AppStorage("ultraFocusEnabled") var ultraFocusEnabled = true

    private let activeKey = "silenceModeActive"
    private let snapshotURL: URL
    private var enforcementTask: Task<Void, Never>?
    private var wasAudioRunning = false
    private var lastNoticeDate = Date.distantPast

    init() {
        isActive = UserDefaults.standard.bool(forKey: activeKey)
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Psst", isDirectory: true)
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        snapshotURL = support.appendingPathComponent("restore-state.json")
        if isActive {
            statusMessage = ultraFocusEnabled
                ? "Ultra Focus sigue protegiendo el silencio."
                : "El modo biblioteca sigue activo."
            Task { @MainActor [weak self] in self?.resumeEnforcement() }
        }
    }

    func toggle() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        if isActive { deactivate() } else { activate() }
    }

    private func activate() {
        var warnings: [String] = []
        do {
            let snapshot = try AudioService.capture()
            save(snapshot)
            try AudioService.silence()
        } catch {
            statusMessage = error.localizedDescription
            return
        }
        if runAutomation && !AutomationService.run(active: true) {
            warnings.append("No se pudo abrir Atajos.")
        }
        isActive = true
        UserDefaults.standard.set(true, forKey: activeKey)
        if ultraFocusEnabled {
            wasAudioRunning = (try? AudioService.enforcementState().isOutputRunning) ?? false
            startEnforcement()
        }
        statusMessage = warnings.isEmpty
            ? activationMessage
            : warnings.joined(separator: " · ")
    }

    private func deactivate() {
        stopEnforcement()
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

    private func resumeEnforcement() {
        if load() == nil, let snapshot = try? AudioService.capture() {
            save(snapshot)
        }
        try? AudioService.silence()
        wasAudioRunning = false
        if ultraFocusEnabled { startEnforcement() }
    }

    private func startEnforcement() {
        enforcementTask?.cancel()
        enforcementTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled, let self, self.isActive else { continue }
                self.enforceSilence()
            }
        }
    }

    private func stopEnforcement() {
        enforcementTask?.cancel()
        enforcementTask = nil
        wasAudioRunning = false
        isShowingBlockedNotice = false
    }

    private func enforceSilence() {
        guard let state = try? AudioService.enforcementState() else { return }
        let playbackStarted = state.isOutputRunning && !wasAudioRunning
        wasAudioRunning = state.isOutputRunning

        if state.needsSilencing {
            preserveNewOutputState()
            try? AudioService.silence()
        }

        if state.needsSilencing || playbackStarted {
            showBlockedNotice()
        }
    }

    private func preserveNewOutputState() {
        guard let current = try? AudioService.capture() else { return }
        let stored = load() ?? SilenceSnapshot(devices: [])
        save(stored.mergingMissingState(from: current))
    }

    private func showBlockedNotice() {
        let now = Date()
        guard now.timeIntervalSince(lastNoticeDate) >= 6 else { return }
        lastNoticeDate = now
        statusMessage = "Ultra Focus ha bloqueado un intento de audio."
        isShowingBlockedNotice = true
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.windows.first(where: { $0.canBecomeKey })?.makeKeyAndOrderFront(nil)
    }

    private var activationMessage: String {
        if ultraFocusEnabled {
            return runAutomation
                ? "Ultra Focus y automatización activos."
                : "Ultra Focus bloquea el audio hasta que desactives Psst."
        }
        return runAutomation
            ? "Silencio y automatización activos."
            : "Audio silenciado. Ultra Focus está desactivado."
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
