import XCTest
@testable import Psst

final class ShortcutURLBuilderTests: XCTestCase {
    func testActivationURLUsesOfficialSchemeAndEncodedName() {
        let url = ShortcutURLBuilder.runURL(active: true)
        XCTAssertEqual(url?.scheme, "shortcuts")
        XCTAssertEqual(url?.host, "run-shortcut")
        XCTAssertTrue(url?.query?.contains("Psst%20Activar%20biblioteca") == true)
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
