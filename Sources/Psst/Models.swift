import Foundation

struct AudioSnapshot: Codable, Equatable {
    let outputVolume: Int
    let alertVolume: Int
    let outputMuted: Bool
}

struct PowerSnapshot: Codable, Equatable {
    var battery: [String: Int] = [:]
    var charger: [String: Int] = [:]

    static let managedKeys = ["lowpowermode", "powernap", "proximitywake", "ttyskeepawake"]
}

struct SilenceSnapshot: Codable, Equatable {
    let audio: AudioSnapshot?
    let power: PowerSnapshot?
}

enum PowerProfileParser {
    static func parse(_ output: String) -> PowerSnapshot {
        var result = PowerSnapshot()
        enum Section { case none, battery, charger }
        var section = Section.none

        for rawLine in output.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line == "Battery Power:" { section = .battery; continue }
            if line == "AC Power:" { section = .charger; continue }

            let fields = line.split(whereSeparator: { $0.isWhitespace })
            guard fields.count >= 2,
                  PowerSnapshot.managedKeys.contains(String(fields[0])),
                  let value = Int(fields[1]) else { continue }

            switch section {
            case .battery: result.battery[String(fields[0])] = value
            case .charger: result.charger[String(fields[0])] = value
            case .none: break
            }
        }
        return result
    }
}
