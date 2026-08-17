import AppKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var silence: SilenceController
    @State private var showingFocusHelp = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: silence.isActive
                    ? [Color(red: 0.04, green: 0.12, blue: 0.14), Color(red: 0.03, green: 0.20, blue: 0.19)]
                    : [Color(red: 0.08, green: 0.10, blue: 0.16), Color(red: 0.12, green: 0.16, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    silenceButton
                    statusCard
                    optionsCard
                    safetyNote
                }
                .padding(32)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingFocusHelp) {
            FocusHelpView()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: silence.isActive ? "moon.stars.fill" : "waveform.path")
                .font(.system(size: 40, weight: .light))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(silence.isActive ? .mint : .white)
            Text("Psst")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            Text("Tu Mac, en modo biblioteca")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var silenceButton: some View {
        Button {
            Task { await silence.toggle() }
        } label: {
            ZStack {
                Circle()
                    .fill(silence.isActive ? Color.mint.opacity(0.18) : Color.white.opacity(0.10))
                    .frame(width: 178, height: 178)
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.14), lineWidth: 1)
                    }
                VStack(spacing: 12) {
                    Image(systemName: silence.isActive ? "speaker.slash.fill" : "power")
                        .font(.system(size: 48, weight: .medium))
                    Text(silence.isActive ? "DESACTIVAR" : "ACTIVAR")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(silence.isBusy)
        .opacity(silence.isBusy ? 0.55 : 1)
        .accessibilityLabel(silence.isActive ? "Desactivar modo biblioteca" : "Activar modo biblioteca")
    }

    private var statusCard: some View {
        HStack(spacing: 14) {
            if silence.isBusy {
                ProgressView().controlSize(.small)
            } else {
                Image(systemName: silence.isActive ? "checkmark.seal.fill" : "circle.dashed")
                    .foregroundStyle(silence.isActive ? .mint : .secondary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(silence.isActive ? "Modo biblioteca activo" : "Listo para guardar silencio")
                    .font(.headline)
                Text(silence.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var optionsCard: some View {
        VStack(spacing: 0) {
            OptionRow(
                icon: "speaker.slash",
                title: "Silenciar audio y avisos",
                detail: "Volumen de salida y alertas a cero",
                isOn: $silence.muteAudio
            )
            Divider().opacity(0.25).padding(.leading, 52)
            OptionRow(
                icon: "leaf",
                title: "Reducir calor y ventiladores",
                detail: "Bajo consumo y menos actividad en reposo",
                isOn: $silence.reduceHeat
            )
            Divider().opacity(0.25).padding(.leading, 52)
            HStack(spacing: 14) {
                Image(systemName: "moon.zzz")
                    .font(.title3)
                    .frame(width: 28)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modo Concentración")
                        .font(.body.weight(.medium))
                    Text(silence.focusAutomationAvailable ? "Automatización preparada" : "Configura dos atajos para bloquear notificaciones")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Configurar") { showingFocusHelp = true }
                    .buttonStyle(.borderless)
            }
            .padding(14)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .disabled(silence.isActive || silence.isBusy)
    }

    private var safetyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundStyle(.mint)
            Text("Psst nunca fuerza los ventiladores por debajo del mínimo seguro. Reduce el calor que los activa y deja la protección térmica en manos de macOS.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

private struct OptionRow: View {
    let icon: String
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(14)
    }
}

private struct FocusHelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "moon.zzz.fill").font(.largeTitle).foregroundStyle(.indigo)
                VStack(alignment: .leading) {
                    Text("Silenciar notificaciones").font(.title2.bold())
                    Text("Integración segura con Atajos de macOS").foregroundStyle(.secondary)
                }
            }

            Text("En Atajos, crea estos dos atajos con la acción “Definir modo de concentración”:")
            VStack(alignment: .leading, spacing: 10) {
                Label("Psst Activar biblioteca — activar No molestar", systemImage: "1.circle.fill")
                Label("Psst Desactivar biblioteca — desactivar No molestar", systemImage: "2.circle.fill")
            }
            .font(.body.weight(.medium))

            Text("Psst los detectará automáticamente. Usar Atajos evita modificar archivos privados del sistema y funciona mejor entre versiones de macOS.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack {
                Button("Abrir Atajos") {
                    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Shortcuts.app"))
                }
                Spacer()
                Button("Hecho") { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
        .frame(width: 500)
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var silence: SilenceController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(silence.isActive ? "Modo biblioteca activo" : "Psst está en espera")
                .font(.headline)
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
