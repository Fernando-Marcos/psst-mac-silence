import Foundation

enum SystemServiceError: LocalizedError {
    case commandFailed(String)
    case invalidAudioState

    var errorDescription: String? {
        switch self {
        case .commandFailed(let detail): return detail.isEmpty ? "El sistema rechazó el cambio." : detail
        case .invalidAudioState: return "No se pudo leer el volumen actual."
        }
    }
}

enum CommandRunner {
    static func run(_ executable: String, _ arguments: [String]) throws -> String {
        let process = Process()
        let output = Pipe()
        let errors = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = errors
        try process.run()
        process.waitUntilExit()
        let stdout = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let stderr = String(decoding: errors.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        guard process.terminationStatus == 0 else {
            throw SystemServiceError.commandFailed(stderr.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func runAsAdministrator(_ command: String) throws {
        let escaped = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        _ = try run("/usr/bin/osascript", ["-e", "do shell script \"\(escaped)\" with administrator privileges"])
    }
}

enum AudioService {
    static func capture() throws -> AudioSnapshot {
        let script = "set s to get volume settings\nreturn (output volume of s as text) & \",\" & (alert volume of s as text) & \",\" & (output muted of s as text)"
        let value = try CommandRunner.run("/usr/bin/osascript", ["-e", script])
        let parts = value.split(separator: ",")
        guard parts.count == 3, let output = Int(parts[0]), let alert = Int(parts[1]) else {
            throw SystemServiceError.invalidAudioState
        }
        return AudioSnapshot(outputVolume: output, alertVolume: alert, outputMuted: parts[2] == "true")
    }

    static func silence() throws {
        _ = try CommandRunner.run("/usr/bin/osascript", ["-e", "set volume output volume 0 alert volume 0 with output muted"])
    }

    static func restore(_ snapshot: AudioSnapshot) throws {
        let muteClause = snapshot.outputMuted ? "with output muted" : "without output muted"
        _ = try CommandRunner.run("/usr/bin/osascript", ["-e", "set volume output volume \(snapshot.outputVolume) alert volume \(snapshot.alertVolume) \(muteClause)"])
    }
}

enum PowerService {
    static func capture() throws -> PowerSnapshot {
        PowerProfileParser.parse(try CommandRunner.run("/usr/bin/pmset", ["-g", "custom"]))
    }

    static func reduceHeat() throws {
        try CommandRunner.runAsAdministrator("/usr/bin/pmset -a lowpowermode 1 powernap 0 proximitywake 0 ttyskeepawake 0")
    }

    static func restore(_ snapshot: PowerSnapshot) throws {
        var commands: [String] = []
        if !snapshot.battery.isEmpty {
            commands.append(pmsetCommand(scope: "-b", values: snapshot.battery))
        }
        if !snapshot.charger.isEmpty {
            commands.append(pmsetCommand(scope: "-c", values: snapshot.charger))
        }
        guard !commands.isEmpty else { return }
        try CommandRunner.runAsAdministrator(commands.joined(separator: "; "))
    }

    private static func pmsetCommand(scope: String, values: [String: Int]) -> String {
        let settings = PowerSnapshot.managedKeys.compactMap { key in
            values[key].map { "\(key) \($0)" }
        }.joined(separator: " ")
        return "/usr/bin/pmset \(scope) \(settings)"
    }
}

enum FocusService {
    static let activateName = "Psst Activar biblioteca"
    static let deactivateName = "Psst Desactivar biblioteca"

    static func isAvailable() -> Bool {
        guard let list = try? CommandRunner.run("/usr/bin/shortcuts", ["list"]) else { return false }
        let names = Set(list.split(separator: "\n").map(String.init))
        return names.contains(activateName) && names.contains(deactivateName)
    }

    static func activate() throws {
        _ = try CommandRunner.run("/usr/bin/shortcuts", ["run", activateName])
    }

    static func deactivate() throws {
        _ = try CommandRunner.run("/usr/bin/shortcuts", ["run", deactivateName])
    }
}
