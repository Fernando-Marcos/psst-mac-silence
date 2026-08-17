import XCTest
@testable import Psst

final class SilenceSnapshotTests: XCTestCase {
    func testSnapshotMergesOnlyPreviouslyUnknownAudioState() {
        let stored = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 7, channels: [
                AudioChannelSnapshot(element: 0, volume: 0.5, muted: 0)
            ])
        ])
        let current = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 7, channels: [
                AudioChannelSnapshot(element: 0, volume: 0, muted: 1),
                AudioChannelSnapshot(element: 1, volume: 0.75, muted: 0)
            ]),
            AudioDeviceSnapshot(deviceID: 9, channels: [
                AudioChannelSnapshot(element: 0, volume: 0.9, muted: 0)
            ])
        ])

        let merged = stored.mergingMissingState(from: current)

        XCTAssertEqual(merged.devices.count, 2)
        XCTAssertEqual(merged.devices[0].channels.count, 2)
        XCTAssertEqual(merged.devices[0].channels[0].volume, 0.5)
        XCTAssertEqual(merged.devices[1].deviceID, 9)
    }

    func testFocusModeRoundTripsThroughRawValue() {
        for mode: FocusMode in [.normal, .soft, .hard] {
            XCTAssertEqual(FocusMode(rawValue: mode.rawValue), mode)
        }
    }

    func testSnapshotRoundTrip() throws {
        let value = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 7, channels: [
                AudioChannelSnapshot(element: 0, volume: 0.5, muted: 0)
            ])
        ])
        let data = try JSONEncoder().encode(value)
        XCTAssertEqual(try JSONDecoder().decode(SilenceSnapshot.self, from: data), value)
    }
}
