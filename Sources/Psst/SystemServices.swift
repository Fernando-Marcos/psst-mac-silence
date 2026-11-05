import CoreAudio
import Foundation

enum SystemServiceError: LocalizedError {
    case audioUnavailable
    case audioChangeRejected
    case outputsDisconnected

    var errorDescription: String? {
        switch self {
        case .audioUnavailable:
            return "No se encontró una salida de audio compatible."
        case .audioChangeRejected:
            return "El dispositivo de audio no permite cambiar su volumen."
        case .outputsDisconnected:
            return "Las salidas que Psst silenció ya no están conectadas. Revisa el volumen al volver a conectarlas."
        }
    }
}

/// Public Core Audio only: no subprocesses, Apple Events or administrator access.
enum AudioService {
    private static let elements: [AudioObjectPropertyElement] = [
        kAudioObjectPropertyElementMain, 1, 2, 3, 4, 5, 6, 7, 8
    ]

    static func capture() throws -> SilenceSnapshot {
        let devices = try defaultDevices().map { device in
            AudioDeviceSnapshot(
                deviceID: device,
                channels: elements.compactMap { captureChannel(device: device, element: $0) },
                uid: deviceUID(device)
            )
        }
        guard devices.contains(where: { !$0.channels.isEmpty }) else {
            throw SystemServiceError.audioUnavailable
        }
        return SilenceSnapshot(devices: devices)
    }

    /// Applies volume 0 and mute to every settable output channel. Mute goes first so there is
    /// no audible step while the volume ramps down on devices that apply changes progressively.
    static func silence() throws {
        var changed = false
        for device in try defaultDevices() {
            for element in elements {
                var muted: UInt32 = 1
                changed = set(&muted, device: device, selector: kAudioDevicePropertyMute, element: element) || changed
                var zero: Float32 = 0
                changed = set(&zero, device: device, selector: kAudioDevicePropertyVolumeScalar, element: element) || changed
            }
        }
        guard changed else { throw SystemServiceError.audioChangeRejected }
    }

    static func enforcementState() throws -> AudioEnforcementState {
        var needsSilencing = false
        var isOutputRunning = false

        for device in try defaultDevices() {
            var running: UInt32 = 0
            if get(
                &running,
                object: device,
                selector: kAudioDevicePropertyDeviceIsRunningSomewhere,
                scope: kAudioObjectPropertyScopeGlobal,
                element: kAudioObjectPropertyElementMain
            ) {
                isOutputRunning = isOutputRunning || running != 0
            }

            for element in elements {
                var volume: Float32 = 0
                if isSettable(device: device, selector: kAudioDevicePropertyVolumeScalar, element: element),
                   get(&volume, object: device, selector: kAudioDevicePropertyVolumeScalar, scope: kAudioDevicePropertyScopeOutput, element: element),
                   volume > 0.0001 {
                    needsSilencing = true
                }

                var muted: UInt32 = 1
                if isSettable(device: device, selector: kAudioDevicePropertyMute, element: element),
                   get(&muted, object: device, selector: kAudioDevicePropertyMute, scope: kAudioDevicePropertyScopeOutput, element: element),
                   muted == 0 {
                    needsSilencing = true
                }
            }
        }

        return AudioEnforcementState(
            needsSilencing: needsSilencing,
            isOutputRunning: isOutputRunning
        )
    }

    /// Restores a sanitized snapshot. Devices are resolved by persistent UID first, so a stored
    /// volume is never written to a different output that happens to reuse an `AudioDeviceID`.
    /// Devices that are no longer connected are skipped and reported instead of failing everything.
    @discardableResult
    static func restore(_ snapshot: SilenceSnapshot) throws -> AudioRestoreReport {
        let safeSnapshot = snapshot.sanitized()
        let connected = connectedDevices()
        var restoredDevices = 0
        var missingDevices = 0

        for device in safeSnapshot.devices {
            guard let target = resolve(device, among: connected) else {
                missingDevices += 1
                continue
            }
            var changed = false
            for channel in device.channels {
                if var volume = channel.volume {
                    changed = set(&volume, device: target, selector: kAudioDevicePropertyVolumeScalar, element: channel.element) || changed
                }
                if var muted = channel.muted {
                    changed = set(&muted, device: target, selector: kAudioDevicePropertyMute, element: channel.element) || changed
                }
            }
            if changed { restoredDevices += 1 }
        }

        guard restoredDevices > 0 else {
            throw missingDevices > 0 ? SystemServiceError.outputsDisconnected : SystemServiceError.audioChangeRejected
        }
        return AudioRestoreReport(restoredDevices: restoredDevices, missingDevices: missingDevices)
    }

    private static func resolve(_ device: AudioDeviceSnapshot, among connected: [AudioDeviceID: String?]) -> AudioDeviceID? {
        if let uid = device.uid {
            return connected.first { $0.value == uid }?.key
        }
        // Snapshots written before 1.5.2 have no UID: only accept an ID that is still connected.
        return connected.keys.contains(device.deviceID) ? device.deviceID : nil
    }

    private static func connectedDevices() -> [AudioDeviceID: String?] {
        var property = address(kAudioHardwarePropertyDevices, scope: kAudioObjectPropertyScopeGlobal, element: kAudioObjectPropertyElementMain)
        let system = AudioObjectID(kAudioObjectSystemObject)
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(system, &property, 0, nil, &size) == noErr, size > 0 else { return [:] }
        let count = Int(size) / MemoryLayout<AudioDeviceID>.size
        guard count > 0, count <= 512 else { return [:] }
        var ids = [AudioDeviceID](repeating: kAudioObjectUnknown, count: count)
        let status = ids.withUnsafeMutableBytes { bytes in
            AudioObjectGetPropertyData(system, &property, 0, nil, &size, bytes.baseAddress!)
        }
        guard status == noErr else { return [:] }
        let returned = min(count, Int(size) / MemoryLayout<AudioDeviceID>.size)
        var result: [AudioDeviceID: String?] = [:]
        for id in ids.prefix(returned) where id != kAudioObjectUnknown {
            result[id] = deviceUID(id)
        }
        return result
    }

    private static func deviceUID(_ device: AudioDeviceID) -> String? {
        var property = address(kAudioDevicePropertyDeviceUID, scope: kAudioObjectPropertyScopeGlobal, element: kAudioObjectPropertyElementMain)
        guard AudioObjectHasProperty(device, &property) else { return nil }
        var uid: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = withUnsafeMutablePointer(to: &uid) { pointer in
            AudioObjectGetPropertyData(device, &property, 0, nil, &size, pointer)
        }
        // Core Audio returns a +1 CFString that the caller owns.
        guard status == noErr, let value = uid?.takeRetainedValue() else { return nil }
        let string = value as String
        return string.isEmpty ? nil : string
    }

    private static func defaultDevices() throws -> [AudioDeviceID] {
        var output: AudioDeviceID = 0
        var system: AudioDeviceID = 0
        guard get(&output, object: AudioObjectID(kAudioObjectSystemObject), selector: kAudioHardwarePropertyDefaultOutputDevice, scope: kAudioObjectPropertyScopeGlobal, element: kAudioObjectPropertyElementMain),
              get(&system, object: AudioObjectID(kAudioObjectSystemObject), selector: kAudioHardwarePropertyDefaultSystemOutputDevice, scope: kAudioObjectPropertyScopeGlobal, element: kAudioObjectPropertyElementMain) else {
            throw SystemServiceError.audioUnavailable
        }
        return Array(Set([output, system]).filter { $0 != kAudioObjectUnknown })
    }

    private static func captureChannel(device: AudioDeviceID, element: AudioObjectPropertyElement) -> AudioChannelSnapshot? {
        var volume: Float32 = 0
        var muted: UInt32 = 0
        let hasVolume = get(&volume, object: device, selector: kAudioDevicePropertyVolumeScalar, scope: kAudioDevicePropertyScopeOutput, element: element)
        let hasMute = get(&muted, object: device, selector: kAudioDevicePropertyMute, scope: kAudioDevicePropertyScopeOutput, element: element)
        guard hasVolume || hasMute else { return nil }
        return AudioChannelSnapshot(element: element, volume: hasVolume ? volume : nil, muted: hasMute ? muted : nil)
    }

    private static func address(_ selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope, element: AudioObjectPropertyElement) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
    }

    private static func get<T>(_ value: inout T, object: AudioObjectID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope, element: AudioObjectPropertyElement) -> Bool {
        var property = address(selector, scope: scope, element: element)
        guard AudioObjectHasProperty(object, &property) else { return false }
        let expectedSize = UInt32(MemoryLayout<T>.size)
        var size = expectedSize
        let status = withUnsafeMutableBytes(of: &value) { bytes in
            AudioObjectGetPropertyData(object, &property, 0, nil, &size, bytes.baseAddress!)
        }
        // Reject partial reads so a short answer never leaves stale bytes in `value`.
        return status == noErr && size == expectedSize
    }

    private static func isSettable(device: AudioDeviceID, selector: AudioObjectPropertySelector, element: AudioObjectPropertyElement) -> Bool {
        var property = address(selector, scope: kAudioDevicePropertyScopeOutput, element: element)
        var result: DarwinBoolean = false
        return AudioObjectIsPropertySettable(device, &property, &result) == noErr && result.boolValue
    }

    private static func set<T>(_ value: inout T, device: AudioDeviceID, selector: AudioObjectPropertySelector, element: AudioObjectPropertyElement) -> Bool {
        guard isSettable(device: device, selector: selector, element: element) else { return false }
        var property = address(selector, scope: kAudioDevicePropertyScopeOutput, element: element)
        return withUnsafeBytes(of: &value) { bytes in
            AudioObjectSetPropertyData(device, &property, 0, nil, UInt32(bytes.count), bytes.baseAddress!) == noErr
        }
    }
}
