import Foundation

struct AudioChannelSnapshot: Codable, Equatable {
    let element: UInt32
    let volume: Float32?
    let muted: UInt32?
}

struct AudioDeviceSnapshot: Codable, Equatable {
    let deviceID: UInt32
    let channels: [AudioChannelSnapshot]
}

struct SilenceSnapshot: Codable, Equatable {
    let devices: [AudioDeviceSnapshot]

    func mergingMissingState(from current: SilenceSnapshot) -> SilenceSnapshot {
        var merged = devices

        for currentDevice in current.devices {
            guard let deviceIndex = merged.firstIndex(where: { $0.deviceID == currentDevice.deviceID }) else {
                merged.append(currentDevice)
                continue
            }

            let existing = merged[deviceIndex]
            let existingElements = Set(existing.channels.map(\.element))
            let missingChannels = currentDevice.channels.filter { !existingElements.contains($0.element) }
            guard !missingChannels.isEmpty else { continue }
            merged[deviceIndex] = AudioDeviceSnapshot(
                deviceID: existing.deviceID,
                channels: existing.channels + missingChannels
            )
        }

        return SilenceSnapshot(devices: merged)
    }
}

struct AudioEnforcementState: Equatable {
    let needsSilencing: Bool
    let isOutputRunning: Bool
}

enum ShortcutURLBuilder {
    static let activateName = "Psst Activar biblioteca"
    static let deactivateName = "Psst Desactivar biblioteca"

    static func runURL(active: Bool) -> URL? {
        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [
            URLQueryItem(name: "name", value: active ? activateName : deactivateName)
        ]
        return components.url
    }
}
