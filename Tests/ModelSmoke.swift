import Foundation

@main
enum ModelSmoke {
    static func main() throws {
        let activeURL = ShortcutURLBuilder.runURL(active: true)
        let inactiveURL = ShortcutURLBuilder.runURL(active: false)
        precondition(activeURL?.scheme == "shortcuts")
        precondition(activeURL?.host == "run-shortcut")
        precondition(activeURL?.query?.contains("Psst%20Activar%20biblioteca") == true)
        precondition(inactiveURL?.query?.contains("Psst%20Desactivar%20biblioteca") == true)

        let snapshot = SilenceSnapshot(devices: [
            AudioDeviceSnapshot(deviceID: 42, channels: [
                AudioChannelSnapshot(element: 0, volume: 0.65, muted: 0)
            ])
        ])
        let restored = try JSONDecoder().decode(SilenceSnapshot.self, from: JSONEncoder().encode(snapshot))
        precondition(restored == snapshot)
        print("OK: URLs seguras de Atajos y restauración de audio verificadas")
    }
}
