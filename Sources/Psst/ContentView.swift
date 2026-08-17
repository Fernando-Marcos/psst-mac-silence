import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var silence: SilenceController
    @State private var showingAutomationHelp = false

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
                safetyFooter
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
        }
        .frame(width: 468, height: 468)
        .preferredColorScheme(.dark)
        .background(WindowGlassConfigurator())
        .sheet(isPresented: $showingAutomationHelp) { AutomationHelpView() }
        .alert("Audio bloqueado por Psst", isPresented: $silence.isShowingBlockedNotice) {
            Button("Mantener silencio", role: .cancel) {}
            Button("Desactivar Psst") { Task { await silence.toggle() } }
        } message: {
            Text("Psst está ejecutando el modo biblioteca. El audio seguirá bloqueado hasta que desactives la aplicación.")
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            Image(systemName: silence.isActive ? "moon.stars.fill" : "waveform.path")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(silence.isActive ? .mint : .cyan)
            Text("Psst").font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Tu Mac, en modo biblioteca").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var silenceButton: some View {
        Button { Task { await silence.toggle() } } label: {
            ZStack {
                Circle()
                    .fill(silence.isActive ? Color.mint.opacity(0.18) : Color.white.opacity(0.09))
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                    .shadow(color: silence.isActive ? .mint.opacity(0.15) : .black.opacity(0.18), radius: 18)
                VStack(spacing: 7) {
                    Image(systemName: silence.isActive ? "speaker.slash.fill" : "power")
                        .font(.system(size: 37, weight: .medium))
                    Text(silence.isActive ? "DESACTIVAR" : "ACTIVAR")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                }
            }
            .frame(width: 122, height: 122)
        }
        .buttonStyle(.plain)
        .disabled(silence.isBusy)
        .opacity(silence.isBusy ? 0.55 : 1)
        .accessibilityLabel(silence.isActive ? "Desactivar modo biblioteca" : "Activar modo biblioteca")
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
                Text(silence.isActive ? "Modo biblioteca activo" : "Listo para guardar silencio")
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
                Image(systemName: "lock.fill").frame(width: 24).foregroundStyle(.mint)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Bloqueo continuo de audio").font(.subheadline.weight(.medium))
                    Text("Impide recuperar el sonido mientras esté activo")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 13)
            .frame(height: 51)
            Divider().opacity(0.22).padding(.leading, 45)
            HStack(spacing: 11) {
                Image(systemName: "moon.zzz").frame(width: 24).foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Concentración y bajo consumo").font(.subheadline.weight(.medium))
                    Text("Automatización opcional de Apple Atajos")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer(minLength: 5)
                Button { showingAutomationHelp = true } label: { Image(systemName: "info.circle") }
                    .buttonStyle(.plain).foregroundStyle(.secondary)
                Toggle("", isOn: $silence.runAutomation).labelsHidden().controlSize(.small)
            }
            .padding(.horizontal, 13)
            .frame(height: 51)
        }
        .glassCard()
        .disabled(silence.isActive || silence.isBusy)
    }

    private var safetyFooter: some View {
        Label("Sandbox de Apple · sin contraseña ni acceso a tus archivos", systemImage: "lock.shield.fill")
            .font(.caption2).foregroundStyle(.secondary).lineLimit(1)
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

private struct AutomationHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Automatización segura", systemImage: "lock.shield.fill")
                .font(.title2.bold()).foregroundStyle(.mint)
            Text("Crea en Atajos estas dos automatizaciones. Añade las acciones de Apple para activar/desactivar No molestar y Bajo consumo si están disponibles en tu versión de macOS:")
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 9) {
                Label(ShortcutURLBuilder.activateName, systemImage: "1.circle.fill")
                Label(ShortcutURLBuilder.deactivateName, systemImage: "2.circle.fill")
            }
            .font(.body.weight(.medium))
            Text("Psst solo abre el esquema oficial shortcuts:// cuando pulsas el botón. No lee tus atajos ni solicita acceso de automatización.")
                .font(.callout).foregroundStyle(.secondary)
            HStack {
                Button("Abrir Atajos") { AutomationService.openShortcuts() }
                Spacer()
                Button("Hecho") { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(26)
        .frame(width: 460)
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var silence: SilenceController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(silence.isActive ? "Modo biblioteca activo" : "Psst está en espera").font(.headline)
            Button(silence.isActive ? "Desactivar" : "Activar modo biblioteca") {
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
}
