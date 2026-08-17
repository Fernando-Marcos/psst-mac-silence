import CoreAudio
import Foundation

enum SystemServiceError: LocalizedError {
    case audioUnavailable
    case audioChangeRejected

    var errorDescription: String? {
        switch self {
        case .audioUnavailable:
            return "No se encontró una salida de audio compatible."
        case .audioChangeRejected:
            return "El dispositivo de audio no permite cambiar su volumen."
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
                channels: elements.compactMap { captureChannel(device: device, element: $0) }
            )
        }
        guard devices.contains(where: { !$0.channels.isEmpty }) else {
            throw SystemServiceError.audioUnavailable
        }
        return SilenceSnapshot(devices: devices)
    }

    static func silence() throws {
        var changed = false
        for device in try defaultDevices() {
            for element in elements {
                if isSettable(device: device, selector: kAudioDevicePropertyVolumeScalar, element: element) {
                    var zero: Float32 = 0
                    changed = set(&zero, device: device, selector: kAudioDevicePropertyVolumeScalar, element: element) || changed
                }
                if isSettable(device: device, selector: kAudioDevicePropertyMute, element: element) {
                    var muted: UInt32 = 1
                    changed = set(&muted, device: device, selector: kAudioDevicePropertyMute, element: element) || changed
                }
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

    static func restore(_ snapshot: SilenceSnapshot) throws {
        var changed = false
        for device in snapshot.devices {
            for channel in device.channels {
                if var volume = channel.volume {
                    changed = set(&volume, device: device.deviceID, selector: kAudioDevicePropertyVolumeScalar, element: channel.element) || changed
                }
                if var muted = channel.muted {
                    changed = set(&muted, device: device.deviceID, selector: kAudioDevicePropertyMute, element: channel.element) || changed
                }
            }
        }
        guard changed else { throw SystemServiceError.audioChangeRejected }
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
        var size = UInt32(MemoryLayout<T>.size)
        return withUnsafeMutableBytes(of: &value) { bytes in
            AudioObjectGetPropertyData(object, &property, 0, nil, &size, bytes.baseAddress!) == noErr
        }
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
