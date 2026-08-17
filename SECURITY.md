# Política de seguridad

## Versiones compatibles

La versión estable más reciente recibe correcciones de seguridad.

## Comunicar una vulnerabilidad

No publiques datos personales ni detalles explotables en una incidencia pública. Usa **Report a vulnerability** en la pestaña Security del repositorio e incluye versión de macOS, modelo de Mac, versión de Psst, reproducción e impacto.

## Modelo de seguridad

Psst está firmado con App Sandbox y el mínimo conjunto de privilegios: únicamente `com.apple.security.app-sandbox`. No ejecuta comandos, no usa AppleScript, no escala a root, no instala helpers, extensiones de kernel ni controladores, y no modifica el SMC.

El audio usa Core Audio. Ultra Focus vigila localmente las propiedades de la salida y vuelve a aplicar mute y volumen cero si cambian; el modo biblioteca normal solo aplica el silencio inicial reversible. Psst no captura audio ni inyecta código en otras aplicaciones. Las acciones de Concentración o Bajo consumo quedan en Atajos, bajo control explícito del usuario. macOS mantiene íntegramente la protección térmica y el control de los ventiladores.

El bloqueo depende de que la salida predeterminada exponga controles de volumen o mute por software. Una interfaz digital o externa que rechace ambos controles no puede silenciarse de forma fiable desde una app sandboxed y Psst muestra el error correspondiente.

La firma ad hoc del ZIP de desarrollo demuestra la configuración técnica del sandbox, pero no sustituye la firma Developer ID, la notarización ni la revisión de Mac App Store necesarias para distribución oficial.
