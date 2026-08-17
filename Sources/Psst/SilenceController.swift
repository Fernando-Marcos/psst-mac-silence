import AppKit
import Foundation
import SwiftUI

@MainActor
final class SilenceController: ObservableObject {
    @Published var isActive: Bool
    @Published var isBusy = false
    @Published var isShowingBlockedNotice = false
    @Published var isShowingSoftPermissionPrompt = false
    @Published var statusMessage = "Silencia el Mac con un toque."
    @Published var focusMode: FocusMode {
        didSet { UserDefaults.standard.set(focusMode.rawValue, forKey: focusModeKey) }
    }

    private let activeKey = "silenceModeActive"
    private let focusModeKey = "focusMode"
    private let snapshotURL: URL
    private var enforcementTask: Task<Void, Never>?
    private var wasAudioRunning = false
    private var lastNoticeDate = Date.distantPast
    private var softAudioAllowed = false

    init() {
        isActive = UserDefaults.standard.bool(forKey: activeKey)
        focusMode = FocusMode(rawValue: UserDefaults.standard.string(forKey: focusModeKey) ?? "") ?? .hard
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Psst", isDirectory: true)
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        snapshotURL = support.appendingPathComponent("restore-state.json")
        if isActive {
            statusMessage = activeStatusMessage
            Task { @MainActor [weak self] in self?.resumeEnforcement() }
        }
    }

    func toggle() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        if isActive { deactivate() } else { activate() }
    }

    /// Called from the Soft Mode alert when the user allows music/video for this session.
    func allowSoftAudio() {
        softAudioAllowed = true
        isShowingSoftPermissionPrompt = false
        if let snapshot = load() {
            try? AudioService.restore(snapshot)
        }
        statusMessage = "Música y vídeo permitidos. Concentración ya no vigila el audio hasta que desactives Psst."
    }

    /// Called from the Soft Mode alert when the user keeps the silence.
    func keepSoftSilence() {
        isShowingSoftPermissionPrompt = false
        try? AudioService.silence()
        statusMessage = "Sonido bloqueado. Concentración sigue en silencio."
    }

    private func activate() {
        do {
            let snapshot = try AudioService.capture()
            save(snapshot)
            try AudioService.silence()
        } catch {
            statusMessage = error.localizedDescription
            return
        }
        isActive = true
        softAudioAllowed = false
        UserDefaults.standard.set(true, forKey: activeKey)
        if focusMode != .normal {
            wasAudioRunning = (try? AudioService.enforcementState().isOutputRunning) ?? false
            startEnforcement()
        }
        statusMessage = activeStatusMessage
    }

    private func deactivate() {
        stopEnforcement()
        var warnings: [String] = []
        if let snapshot = load() {
            do { try AudioService.restore(snapshot) }
            catch { warnings.append(error.localizedDescription) }
        }
        isActive = false
        softAudioAllowed = false
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
        softAudioAllowed = false
        if focusMode != .normal { startEnforcement() }
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
        isShowingSoftPermissionPrompt = false
    }

    private func enforceSilence() {
        guard let state = try? AudioService.enforcementState() else { return }
        let playbackStarted = state.isOutputRunning && !wasAudioRunning
        wasAudioRunning = state.isOutputRunning

        switch focusMode {
        case .normal:
            return

        case .hard:
            if state.needsSilencing {
                preserveNewOutputState()
                try? AudioService.silence()
            }
            if state.needsSilencing || playbackStarted {
                showBlockedNotice()
            }

        case .soft:
            guard !softAudioAllowed else { return }
            if state.needsSilencing {
                preserveNewOutputState()
                try? AudioService.silence()
            }
            if playbackStarted {
                showSoftPermissionPrompt()
            }
        }
    }

    private func preserveNewOutputState() {
        guard let current = try? AudioService.capture() else { return }
        let stored = load() ?? SilenceSnapshot(devices: [])
        save(stored.mergingMissingState(from: current))
    }

    private func showBlockedNotice() {
        guard shouldShowNotice() else { return }
        statusMessage = "Ultra Focus ha bloqueado un intento de audio."
        isShowingBlockedNotice = true
        bringWindowForward()
    }

    private func showSoftPermissionPrompt() {
        guard shouldShowNotice() else { return }
        statusMessage = "Un sonido quiere reproducirse. Concentración espera tu permiso."
        isShowingSoftPermissionPrompt = true
        bringWindowForward()
    }

    private func shouldShowNotice() -> Bool {
        let now = Date()
        guard now.timeIntervalSince(lastNoticeDate) >= 6 else { return false }
        lastNoticeDate = now
        return true
    }

    private func bringWindowForward() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSApplication.shared.windows.first(where: { $0.canBecomeKey })?.makeKeyAndOrderFront(nil)
    }

    private var activeStatusMessage: String {
        switch focusMode {
        case .hard:
            return "Ultra Focus bloquea el audio hasta que desactives Psst."
        case .soft:
            return "Concentración silencia el equipo y te avisa antes de dejar sonar música o vídeo."
        case .normal:
            return "Audio silenciado. Modo biblioteca sin vigilancia continua."
        }
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
