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
            ])
        ])
        let restored = try JSONDecoder().decode(SilenceSnapshot.self, from: JSONEncoder().encode(snapshot))
        precondition(restored == snapshot)
        print("OK: modos de enfoque y restauración de audio verificados")
    }
}
