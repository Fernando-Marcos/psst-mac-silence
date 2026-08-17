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
