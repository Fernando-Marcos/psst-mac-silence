import Foundation

struct AudioChannelSnapshot: Codable, Equatable {
    let element: UInt32
    let volume: Float32?
    let muted: UInt32?
}

struct AudioDeviceSnapshot: Codable, Equatable {
    let deviceID: UInt32
    let channels: [AudioChannelSnapshot]
    /// Persistent Core Audio UID. `AudioDeviceID` values are not stable across reboots or
    /// reconnections, so restoring by UID avoids writing a stored volume to the wrong output.
    /// Optional to keep decoding snapshots written by versions prior to 1.5.2.
    var uid: String?

    func refers(to other: AudioDeviceSnapshot) -> Bool {
        if let uid, let otherUID = other.uid { return uid == otherUID }
        return deviceID == other.deviceID
    }
}

struct SilenceSnapshot: Codable, Equatable {
    /// Upper bounds for data read back from disk. A real Mac exposes the default output and the
    /// system-sounds output (often the same device) with at most 9 inspected elements each.
    static let maxDevices = 16
    static let maxElement: UInt32 = 8
    static let maxUIDLength = 512
    static let maxEncodedSize = 64 * 1024

    let devices: [AudioDeviceSnapshot]

    var isEmpty: Bool { !devices.contains { !$0.channels.isEmpty } }

    func mergingMissingState(from current: SilenceSnapshot) -> SilenceSnapshot {
        var merged = devices

        for currentDevice in current.devices {
            guard let deviceIndex = merged.firstIndex(where: { $0.refers(to: currentDevice) }) else {
                merged.append(currentDevice)
                continue
            }

            let existing = merged[deviceIndex]
            let existingElements = Set(existing.channels.map(\.element))
            let missingChannels = currentDevice.channels.filter { !existingElements.contains($0.element) }
            guard !missingChannels.isEmpty else { continue }
            merged[deviceIndex] = AudioDeviceSnapshot(
                deviceID: existing.deviceID,
                channels: existing.channels + missingChannels,
                uid: existing.uid ?? currentDevice.uid
            )
        }

        return SilenceSnapshot(devices: merged).sanitized()
    }

    /// Returns a copy that only contains values Core Audio can legitimately accept:
    /// finite volumes clamped to 0...1, mute flags as 0/1, known elements, no duplicates
    /// and bounded sizes. Protects restoration against a corrupted or tampered file.
    func sanitized() -> SilenceSnapshot {
        var seenDevices: [AudioDeviceSnapshot] = []

        for device in devices {
            guard seenDevices.count < Self.maxDevices else { break }
            guard device.deviceID != 0 else { continue }
            let uid = device.uid.flatMap { value -> String? in
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty, trimmed.utf8.count <= Self.maxUIDLength else { return nil }
                return trimmed
            }
            let candidate = AudioDeviceSnapshot(deviceID: device.deviceID, channels: [], uid: uid)
            guard !seenDevices.contains(where: { $0.refers(to: candidate) }) else { continue }

            var seenElements = Set<UInt32>()
            var channels: [AudioChannelSnapshot] = []
            for channel in device.channels where channel.element <= Self.maxElement {
                guard seenElements.insert(channel.element).inserted else { continue }
                let volume = channel.volume.flatMap { $0.isFinite ? min(max($0, 0), 1) : nil }
                let muted = channel.muted.map { $0 == 0 ? UInt32(0) : UInt32(1) }
                guard volume != nil || muted != nil else { continue }
                channels.append(AudioChannelSnapshot(element: channel.element, volume: volume, muted: muted))
            }

            seenDevices.append(AudioDeviceSnapshot(deviceID: device.deviceID, channels: channels, uid: uid))
        }

        return SilenceSnapshot(devices: seenDevices)
    }

    /// Decodes a stored snapshot with a size limit and sanitizes it before use.
    static func decodeValidated(from data: Data) throws -> SilenceSnapshot {
        guard data.count <= maxEncodedSize else { throw SnapshotError.tooLarge }
        let decoded = try JSONDecoder().decode(SilenceSnapshot.self, from: data).sanitized()
        guard !decoded.isEmpty else { throw SnapshotError.empty }
        return decoded
    }
}

enum SnapshotError: Error, Equatable {
    case tooLarge
    case empty
}

struct AudioEnforcementState: Equatable {
    let needsSilencing: Bool
    let isOutputRunning: Bool
}

struct AudioRestoreReport: Equatable {
    let restoredDevices: Int
    let missingDevices: Int
}

enum FocusMode: String {
    case normal
    case soft
    case hard

    var displayName: String {
        switch self {
        case .normal: return "modo Biblioteca"
        case .soft: return "Concentración"
        case .hard: return "Ultra Focus"
        }
    }
}
