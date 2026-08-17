# Arquitectura y decisiones de seguridad

Psst es una app SwiftUI/AppKit nativa para macOS 13 o posterior, compilada como binario universal.

## Componentes

- `PsstApp.swift`: ciclo de vida, ventana fija y menú de la barra de menús.
- `ContentView.swift`: interfaz compacta y material translúcido con `NSVisualEffectView`.
- `SilenceController.swift`: estado, selección de Ultra Focus, vigilancia opcional, avisos, restauración y persistencia reversible.
- `SystemServices.swift`: Core Audio y apertura segura del esquema de Atajos.
- `Models.swift`: instantánea de audio y construcción de URL.
- `Psst.entitlements`: sandbox mínimo verificable en la firma.

## Flujo de activación

1. Core Audio obtiene el dispositivo de salida y el dispositivo de sonidos del sistema.
2. La app guarda volumen y mute por canales disponibles dentro de su contenedor.
3. Core Audio lleva a cero y silencia todas las propiedades de salida modificables.
4. Si el usuario lo habilitó, la app abre `shortcuts://run-shortcut` con el atajo de activación.
5. Si Ultra Focus está habilitado, un ciclo local comprueba cada 400 ms el estado de mute, volumen y actividad genérica del dispositivo.
6. En Ultra Focus, si el volumen reaparece, Psst conserva el estado original de una salida nueva, vuelve a silenciarla y presenta el aviso de bloqueo. En el modo normal no existe vigilancia continua.

La desactivación detiene primero cualquier vigilancia de Ultra Focus, restaura la instantánea y abre el atajo inverso. Los dispositivos digitales que no exponen control de volumen por software pueden rechazar el cambio; Psst lo comunica sin intentar eludir macOS.

La señal de actividad procede de `kAudioDevicePropertyDeviceIsRunningSomewhere`. Es un indicador del dispositivo, no una captura de sonido: Psst no recibe muestras de audio, no conoce el contenido reproducido y no identifica la aplicación que lo originó.

## Límite térmico intencionado

No existe control directo de ventiladores, escritura SMC ni `pmset`. Reducir artificialmente la refrigeración puede comprometer la seguridad del hardware y no es compatible con el modelo de sandbox. El Bajo consumo es una automatización opcional de Apple Atajos, configurada y autorizada por el usuario.

## Superficie de privilegios

El binario no contiene `Process`, comandos de shell, `osascript`, Apple Events ni mecanismos de autorización administrativa. El entitlement no concede red, archivos, dispositivos ni datos personales. La única escritura se realiza en el contenedor privado de App Sandbox.

La CI inspecciona el entitlement incorporado a la firma, valida el bundle y confirma las arquitecturas `arm64` y `x86_64`.
