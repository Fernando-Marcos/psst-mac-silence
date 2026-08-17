# Arquitectura y decisiones de seguridad

Psst es una app SwiftUI/AppKit nativa para macOS 13 o posterior, compilada como binario universal.

## Componentes

- `PsstApp.swift`: ciclo de vida, ventana fija y menú de la barra de menús.
- `ContentView.swift`: interfaz compacta y material translúcido con `NSVisualEffectView`.
- `SilenceController.swift`: estado, selección de modo (Biblioteca, Concentración o Ultra Focus), vigilancia opcional, avisos, restauración y persistencia reversible.
- `SystemServices.swift`: integración con Core Audio.
- `Models.swift`: instantánea de audio y el enum `FocusMode`.
- `Psst.entitlements`: sandbox mínimo verificable en la firma.

## Flujo de activación

1. Core Audio obtiene el dispositivo de salida y el dispositivo de sonidos del sistema.
2. La app guarda volumen y mute por canales disponibles dentro de su contenedor.
3. Core Audio lleva a cero y silencia todas las propiedades de salida modificables, sea cual sea el modo elegido (Biblioteca, Concentración o Ultra Focus).
4. Si el modo activo no es Biblioteca, un ciclo local comprueba cada 400 ms el estado de mute, volumen y actividad genérica del dispositivo.
5. En Ultra Focus, si el volumen reaparece, Psst conserva el estado original de una salida nueva, vuelve a silenciarla y presenta el aviso de bloqueo, sin dar opción a permitirlo.
6. En Concentración, si se detecta el inicio de reproducción, Psst mantiene el silencio y muestra un aviso pidiendo permiso antes de que se oiga nada. Si el usuario permite el sonido, Psst restaura el volumen guardado y deja de vigilar el audio hasta que se desactive; si elige mantener el silencio, sigue bloqueando futuros intentos igual que Ultra Focus. En el modo Biblioteca no existe vigilancia continua.

La desactivación detiene primero cualquier vigilancia activa y restaura la instantánea guardada. Los dispositivos digitales que no exponen control de volumen por software pueden rechazar el cambio; Psst lo comunica sin intentar eludir macOS.

La señal de actividad procede de `kAudioDevicePropertyDeviceIsRunningSomewhere`. Es un indicador del dispositivo, no una captura de sonido: Psst no recibe muestras de audio, no conoce el contenido reproducido y no identifica la aplicación que lo originó.

## Límite térmico intencionado

No existe control directo de ventiladores, escritura SMC ni `pmset`. Reducir artificialmente la refrigeración puede comprometer la seguridad del hardware y no es compatible con el modelo de sandbox. macOS conserva siempre el control térmico y del Bajo consumo.

## Superficie de privilegios

El binario no contiene `Process`, comandos de shell, `osascript`, Apple Events ni mecanismos de autorización administrativa. El entitlement no concede red, archivos, dispositivos ni datos personales. La única escritura se realiza en el contenedor privado de App Sandbox.

La CI inspecciona el entitlement incorporado a la firma, valida el bundle y confirma las arquitecturas `arm64` y `x86_64`.
