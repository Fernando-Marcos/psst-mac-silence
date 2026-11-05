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

final class SnapshotHardeningTests: XCTestCase {
    func testLegacySnapshotWithoutUIDStillDecodes() throws {
        let legacy = Data(#"{"devices":[{"deviceID":42,"channels":[{"element":0,"volume":0.5,"muted":0}]}]}"#.utf8)
        let snapshot = try SilenceSnapshot.decodeValidated(from: legacy)
        XCTAssertNil(snapshot.devices.first?.uid)
        XCTAssertEqual(snapshot.devices.first?.channels.first?.volume, 0.5)
    }

    func testSanitizeClampsAndDropsInvalidValues() {
        let snapshot = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 7, channels: [
                AudioChannelSnapshot(element: 0, volume: 7.5, muted: 9),
                AudioChannelSnapshot(element: 0, volume: 0.1, muted: 0),
                AudioChannelSnapshot(element: 99, volume: 0.3, muted: 0),
                AudioChannelSnapshot(element: 1, volume: .nan, muted: nil),
                AudioChannelSnapshot(element: 2, volume: -1, muted: nil)
            ]),
            AudioDeviceSnapshot(deviceID: 0, channels: [AudioChannelSnapshot(element: 0, volume: 1, muted: 0)])
        ]).sanitized()

        XCTAssertEqual(snapshot.devices.count, 1)
        XCTAssertEqual(snapshot.devices[0].channels, [
            AudioChannelSnapshot(element: 0, volume: 1, muted: 1),
            AudioChannelSnapshot(element: 2, volume: 0, muted: nil)
        ])
    }

    func testSanitizeBoundsDeviceCountAndUIDLength() {
        let devices = (1...40).map {
            AudioDeviceSnapshot(deviceID: UInt32($0), channels: [AudioChannelSnapshot(element: 0, volume: 0.5, muted: 0)],
                                uid: String(repeating: "x", count: SilenceSnapshot.maxUIDLength + 1))
        }
        let snapshot = SilenceSnapshot(devices: devices).sanitized()
        XCTAssertEqual(snapshot.devices.count, SilenceSnapshot.maxDevices)
        XCTAssertTrue(snapshot.devices.allSatisfy { $0.uid == nil })
    }

    func testOversizedAndEmptySnapshotsAreRejected() {
        let oversized = Data(repeating: 0x20, count: SilenceSnapshot.maxEncodedSize + 1)
        XCTAssertThrowsError(try SilenceSnapshot.decodeValidated(from: oversized)) {
            XCTAssertEqual($0 as? SnapshotError, .tooLarge)
        }
        let empty = Data(#"{"devices":[]}"#.utf8)
        XCTAssertThrowsError(try SilenceSnapshot.decodeValidated(from: empty)) {
            XCTAssertEqual($0 as? SnapshotError, .empty)
        }
    }

    func testMergeMatchesReconnectedDeviceByUID() {
        let stored = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 10, channels: [AudioChannelSnapshot(element: 0, volume: 0.4, muted: 0)], uid: "USB-1")
        ])
        let current = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 55, channels: [
                AudioChannelSnapshot(element: 0, volume: 0, muted: 1),
                AudioChannelSnapshot(element: 1, volume: 0.8, muted: 0)
            ], uid: "USB-1")
        ])
        let merged = stored.mergingMissingState(from: current)
        XCTAssertEqual(merged.devices.count, 1)
        XCTAssertEqual(merged.devices[0].channels.first?.volume, 0.4)
        XCTAssertEqual(merged.devices[0].channels.count, 2)
    }
}
