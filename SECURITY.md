# Política de seguridad

## Versiones compatibles

La versión estable más reciente recibe correcciones de seguridad. Cada build de la CI publica la suma SHA-256 del ZIP para que puedas comprobar la descarga con `shasum -a 256 Psst-macOS-universal.zip`.

## Comunicar una vulnerabilidad

No publiques datos personales ni detalles explotables en una incidencia pública. Usa **Report a vulnerability** en la pestaña Security del repositorio e incluye versión de macOS, modelo de Mac, versión de Psst, reproducción e impacto.

## Modelo de seguridad

Psst está firmado con App Sandbox y el mínimo conjunto de privilegios: únicamente `com.apple.security.app-sandbox`. No ejecuta comandos, no usa AppleScript, no escala a root, no instala helpers, extensiones de kernel ni controladores, y no modifica el SMC.

Cada push pasa por `Scripts/check-privileges.sh`, que falla si el código empieza a usar procesos, AppleScript, Apple Events, red, escalada de privilegios o IOKit, o si la firma lleva algún entitlement distinto de App Sandbox. La CI también escanea secretos con Gitleaks y fija sus acciones por hash.

La instantánea de volumen se valida antes de restaurarla (tamaño, rangos y número de dispositivos) y las salidas se identifican por su UID persistente, de modo que un archivo dañado o un cambio de dispositivo no pueden aplicar valores fuera de rango ni a la salida equivocada.

El audio usa Core Audio. Ultra Focus vigila localmente las propiedades de la salida y vuelve a aplicar mute y volumen cero si cambian, sin dar opción a permitirlo; Concentración (Soft Mode) hace la misma vigilancia pero, ante un intento de reproducir sonido, pide permiso explícito antes de restaurar el audio; el modo Biblioteca solo aplica el silencio inicial reversible, sin vigilancia continua. Psst no captura audio ni inyecta código en otras aplicaciones. macOS mantiene íntegramente la protección térmica y el control de los ventiladores.

El bloqueo depende de que la salida predeterminada exponga controles de volumen o mute por software. Una interfaz digital o externa que rechace ambos controles no puede silenciarse de forma fiable desde una app sandboxed y Psst muestra el error correspondiente.

La firma ad hoc del ZIP de desarrollo demuestra la configuración técnica del sandbox, pero no sustituye la firma Developer ID, la notarización ni la revisión de Mac App Store necesarias para distribución oficial.
