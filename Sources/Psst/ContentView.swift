import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var silence: SilenceController

    private var hardModeBinding: Binding<Bool> {
        Binding(
            get: { silence.focusMode == .hard },
            set: { silence.focusMode = $0 ? .hard : .normal }
        )
    }

    private var softModeBinding: Binding<Bool> {
        Binding(
            get: { silence.focusMode == .soft },
            set: { silence.focusMode = $0 ? .soft : .normal }
        )
    }

    var body: some View {
        ZStack {
            GlassBackground().ignoresSafeArea()
            LinearGradient(
                colors: silence.isActive
                    ? [Color.mint.opacity(0.18), Color(red: 0.01, green: 0.15, blue: 0.15).opacity(0.55)]
                    : [Color.purple.opacity(0.18), Color(red: 0.02, green: 0.08, blue: 0.10).opacity(0.56)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 10) {
                header
                silenceButton
                statusCard
                optionsCard
                Spacer(minLength: 10)
                safetyFooter
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
        }
        .frame(width: 468, height: 468)
        .preferredColorScheme(.dark)
        .background(WindowGlassConfigurator())
        .alert("Audio bloqueado por Ultra Focus", isPresented: $silence.isShowingBlockedNotice) {
            Button("Mantener silencio", role: .cancel) {}
            Button("Desactivar Psst") { Task { await silence.toggle() } }
        } message: {
            Text("Ultra Focus (Hard Mode) está activo. El audio seguirá bloqueado hasta que desactives Psst.")
        }
        .alert("¿Permitir música o vídeo?", isPresented: $silence.isShowingSoftPermissionPrompt) {
            Button("Mantener en silencio", role: .cancel) { silence.keepSoftSilence() }
            Button("Permitir") { silence.allowSoftAudio() }
        } message: {
            Text("Concentración (Soft Mode) detectó un intento de reproducir sonido. Permítelo si vas a escuchar música o un podcast con cascos; Psst dejará de vigilar el audio hasta que lo desactives.")
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            if silence.isActive {
                animatedHeaderIcon(systemName: "speaker.slash.fill", base: .red.opacity(0.55), highlight: Color(red: 1, green: 0.42, blue: 0.42))
            } else {
                animatedHeaderIcon(systemName: "speaker.wave.2.fill", base: .green.opacity(0.55), highlight: .mint)
            }
            Text("Psst").font(.system(size: 34, weight: .bold, design: .rounded))
            Text("El silencio que tú eliges").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    /// Degradado horizontal en bucle perfecto: la ventana visible avanza dos periodos completos
    /// del patrón `base → highlight → base` (definido cada 1/6) y, al reiniciarse, cae exactamente
    /// sobre una repetición idéntica del patrón, por lo que el barrido izquierda→derecha no da saltos.
    private func animatedHeaderIcon(systemName: String, base: Color, highlight: Color) -> some View {
        let stops: [Gradient.Stop] = [
            .init(color: base, location: 0.0 / 6),
            .init(color: highlight, location: 1.0 / 6),
            .init(color: base, location: 2.0 / 6),
            .init(color: highlight, location: 3.0 / 6),
            .init(color: base, location: 4.0 / 6),
            .init(color: highlight, location: 5.0 / 6),
            .init(color: base, location: 6.0 / 6)
        ]
        let windowWidth = 1.0 / 3.0

        return TimelineView(.animation) { timeline in
            let duration = 3.4
            let t = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: duration) / duration
            let windowStart = t * (1 - windowWidth)

            Image(systemName: systemName)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(stops: stops),
                        startPoint: UnitPoint(x: windowStart, y: 0.5),
                        endPoint: UnitPoint(x: windowStart + windowWidth, y: 0.5)
                    )
                )
        }
        .frame(width: 24, height: 24)
    }

    private var silenceButton: some View {
        Button { Task { await silence.toggle() } } label: {
            ZStack {
                if !silence.isBusy {
                    inviteRing(color: silence.isActive ? .red : .mint)
                }
                Circle()
                    .fill(silence.isActive ? Color.mint.opacity(0.18) : Color.white.opacity(0.09))
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    .shadow(color: silence.isActive ? .mint.opacity(0.15) : .black.opacity(0.18), radius: 18)
                VStack(spacing: 7) {
                    Image(systemName: silence.isActive ? "power" : "speaker.slash.fill")
                        .font(.system(size: 37, weight: .medium))
                    Text(silence.isActive ? "DESACTIVAR" : "ACTIVAR")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                }
            }
            .frame(width: 134, height: 134)
        }
        .buttonStyle(.plain)
        .disabled(silence.isBusy)
        .opacity(silence.isBusy ? 0.55 : 1)
        .accessibilityLabel(silence.isActive
            ? "Desactivar \(silence.focusMode.displayName)"
            : "Activar \(silence.focusMode.displayName)")
    }

    private func inviteRing(color: Color) -> some View {
        TimelineView(.animation) { timeline in
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [.clear, color.opacity(0.85), .clear],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 134, height: 134)
                .rotationEffect(.degrees(
                    timeline.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: 3.2) / 3.2 * 360
                ))
        }
    }

    private var statusCard: some View {
        HStack(spacing: 11) {
            if silence.isBusy {
                ProgressView().controlSize(.small)
            } else {
                Image(systemName: silence.isActive ? "checkmark.seal.fill" : "circle.dashed")
                    .foregroundStyle(silence.isActive ? .mint : .secondary)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(silence.isActive ? statusTitle : "Listo para guardar silencio")
                    .font(.subheadline.weight(.semibold))
                Text(silence.statusMessage)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .glassCard()
    }

    private var optionsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                Image(systemName: "bolt.shield.fill").frame(width: 24).foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Ultra Focus (Hard Mode)").font(.subheadline.weight(.semibold))
                    Text("Bloquea cualquier intento de recuperar el audio")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Toggle("", isOn: hardModeBinding).labelsHidden().controlSize(.small).tint(.mint)
            }
            .padding(.horizontal, 13)
            .frame(height: 51)
            Divider().opacity(0.22).padding(.leading, 45)
            HStack(spacing: 11) {
                Image(systemName: "headphones").frame(width: 24).foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Concentración (Soft Mode)").font(.subheadline.weight(.medium))
                    Text("Silencia todo y pide permiso antes de dejar sonar música o vídeo")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Toggle("", isOn: softModeBinding).labelsHidden().controlSize(.small).tint(.mint)
            }
            .padding(.horizontal, 13)
            .frame(height: 51)
        }
        .glassCard()
        .disabled(silence.isActive || silence.isBusy)
    }

    private var safetyFooter: some View {
        Label("Silencio para concentrarte. Respeto para no molestar.", systemImage: "speaker.slash.fill")
            .font(.caption2).foregroundStyle(.secondary).lineLimit(1)
    }

    private var statusTitle: String {
        switch silence.focusMode {
        case .hard: return "Ultra Focus activo"
        case .soft: return "Concentración activa"
        case .normal: return "Modo Biblioteca activo"
        }
    }
}

private extension View {
    func glassCard() -> some View {
        background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(.white.opacity(0.10), lineWidth: 1))
    }
}

private struct GlassBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

private struct WindowGlassConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { configure(view.window) }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { configure(nsView.window) }
    }
    private func configure(_ window: NSWindow?) {
        window?.isOpaque = false
        window?.backgroundColor = .clear
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var silence: SilenceController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(silence.isActive ? statusTitle : "Psst está en espera")
                .font(.headline)

            Divider()

            modeItem(.normal, title: "Modo Biblioteca")
            modeItem(.soft, title: "Concentración (Soft Mode)")
            modeItem(.hard, title: "Ultra Focus (Hard Mode)")

            Divider()

            Button(silence.isActive ? "Desactivar" : "Activar \(silence.focusMode.displayName)") {
                Task { await silence.toggle() }
            }
            .disabled(silence.isBusy)

            Divider()

            Button("Abrir Psst") {
                openWindow(id: "main")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            Button("Salir") { NSApplication.shared.terminate(nil) }
        }
        .padding(4)
    }

    @ViewBuilder
    private func modeItem(_ mode: FocusMode, title: String) -> some View {
        Button {
            silence.focusMode = mode
            if !silence.isActive {
                Task { await silence.toggle() }
            }
        } label: {
            HStack {
                Text(title)
                if silence.focusMode == mode {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
        .disabled(silence.isActive || silence.isBusy)
    }

    private var statusTitle: String {
        switch silence.focusMode {
        case .hard: return "Ultra Focus activo"
        case .soft: return "Concentración activa"
        case .normal: return "Modo Biblioteca activo"
        }
    }
}
