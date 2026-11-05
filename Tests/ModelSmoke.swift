import Foundation

@main
enum ModelSmoke {
    static func main() throws {
        precondition(FocusMode(rawValue: "soft") == .soft)
        precondition(FocusMode(rawValue: "hard") == .hard)
        precondition(FocusMode(rawValue: "normal") == .normal)
        precondition(FocusMode(rawValue: "bogus") == nil)

        let snapshot = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 42, channels: [
                AudioChannelSnapshot(element: 0, volume: 0.65, muted: 0)
            ], uid: "BuiltInSpeakerDevice")
        ])
        let restored = try SilenceSnapshot.decodeValidated(from: JSONEncoder().encode(snapshot))
        precondition(restored == snapshot)

        // Snapshots written before 1.5.2 have no UID and must still decode.
        let legacy = Data(#"{"devices":[{"deviceID":42,"channels":[{"element":0,"volume":0.5,"muted":0}]}]}"#.utf8)
        let decodedLegacy = try SilenceSnapshot.decodeValidated(from: legacy)
        precondition(decodedLegacy.devices.first?.uid == nil)

        // Tampered values are clamped or dropped before reaching Core Audio.
        let tampered = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 7, channels: [
                AudioChannelSnapshot(element: 0, volume: 7.5, muted: 9),
                AudioChannelSnapshot(element: 0, volume: 0.1, muted: 0),
                AudioChannelSnapshot(element: 99, volume: 0.3, muted: 0),
                AudioChannelSnapshot(element: 1, volume: .nan, muted: nil),
                AudioChannelSnapshot(element: 2, volume: -1, muted: nil)
            ])
        ]).sanitized()
        precondition(tampered.devices[0].channels == [
            AudioChannelSnapshot(element: 0, volume: 1, muted: 1),
            AudioChannelSnapshot(element: 2, volume: 0, muted: nil)
        ])

        var oversized = Data(repeating: 0x20, count: SilenceSnapshot.maxEncodedSize + 1)
        oversized.append(contentsOf: Array("{}".utf8))
        do {
            _ = try SilenceSnapshot.decodeValidated(from: oversized)
            preconditionFailure("an oversized snapshot must be rejected")
        } catch let error as SnapshotError {
            precondition(error == .tooLarge)
        }

        // A device that reappears with another ID is matched by UID, not duplicated.
        let stored = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 10, channels: [AudioChannelSnapshot(element: 0, volume: 0.4, muted: 0)], uid: "USB-1")
        ])
        let current = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 55, channels: [AudioChannelSnapshot(element: 0, volume: 0, muted: 1)], uid: "USB-1")
        ])
        let merged = stored.mergingMissingState(from: current)
        precondition(merged.devices.count == 1 && merged.devices[0].channels[0].volume == 0.4)

        print("OK: modos de enfoque, validación y restauración de audio verificados")
    }
}
