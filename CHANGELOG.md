# Historial de cambios

## [1.5.0] - 2026-08-18

- Intercambia los iconos del botón principal: **ACTIVAR** ahora muestra el icono de silenciar y **DESACTIVAR** el de encendido, para que el icono anticipe la acción que vas a provocar en lugar del estado actual.
- Añade un anillo animado y muy sutil alrededor del botón principal que gira sin pausa: verde menta en **ACTIVAR** (invita a pulsar) y rojo en **DESACTIVAR** (avisa de que al pulsar se detiene el silencio). Se implementa con un reloj continuo (`TimelineView`) para que nunca se quede congelado al alternar entre estados.
- Rehace el panel **Acerca de Psst**: el eslogan pasa a dos líneas centradas ("Silencio para concentrarte." / "Respeto para no molestar.") y el nombre del autor en el aviso de copyright es ahora un enlace a fernandomarcos.com.
- Actualiza la versión mostrada en "Acerca de Psst" a 1.5.0.
- Añade un icono con degradado animado sobre "Psst" (verde en reposo, rojo al silenciar) que indica si hay sonido; el barrido usa un patrón horizontal con periodo exacto para no dar saltos al reiniciarse.
- Actualiza la captura del README a la interfaz de 1.5.0, con esquinas redondeadas para integrarse con el resto de imágenes del repositorio.
- Sustituye el icono del pie de la ventana principal (candado con escudo) por un altavoz tachado, más identificativo de lo que hace la app, con el mismo tamaño y estilo que el texto que acompaña.

## [1.4.0] - 2026-08-17

- Añade **Concentración (Soft Mode)**: silencia todo el equipo y pide permiso mediante un aviso antes de dejar sonar música, podcast o vídeo con auriculares.
- El permiso concedido en Concentración dura hasta desactivar Psst; mantener el silencio conserva la vigilancia como en Ultra Focus.
- Los tres modos (Biblioteca, Concentración, Ultra Focus) pasan a ser mutuamente excluyentes.
- Elimina la integración con Atajos (automatización de No molestar y Bajo consumo): reducía la superficie del proyecto sin aportar al nuevo modelo de modos.
- Actualiza el pie de la ventana principal a "Silencio para concentrarte. Respeto para no molestar."
- Corrige textos de la interfaz que seguían mencionando únicamente "modo biblioteca" (subtítulo, etiqueta de accesibilidad del botón principal y menú de la barra de menús) para que reflejen el modo realmente seleccionado.
- Corrige la versión mostrada en "Acerca de Psst", que seguía en 1.3.0.
- Sustituye el icono de la app por un nuevo diseño (altavoz silenciado en degradado azul-violeta); se genera ahora desde un PNG maestro (`docs/images/app-icon.png`) con `Scripts/build-icon.sh` en lugar de dibujarse por código.
- Rediseña el README con mejor jerarquía visual, primeros pasos, preguntas frecuentes, casos de uso para trabajadores/coworkers y datos de contacto del autor.
- El menú de la barra de menús permite elegir cualquiera de los tres modos (con marca de verificación en el seleccionado) y activarlo o desactivarlo sin necesidad de abrir la ventana principal.
- Elegir un modo en el menú de la barra lo activa al instante si Psst estaba inactiva, sin pulsar un botón aparte.
- Escribe **Biblioteca** con mayúscula inicial allá donde nombra el modo, igual que Concentración y Ultra Focus.
- Sustituye los iconos de la cabecera de la ventana principal: la onda de sonido por un altavoz con sonido, y la luna por un altavoz tachado, conservando los colores cian y menta originales.

## [1.3.0] - 2026-08-17

- Presenta el bloqueo continuo como el modo opcional **Ultra Focus (Hard Mode)**.
- Añade un interruptor visible que solo puede modificarse con Psst inactivo.
- Distingue claramente el estado, los avisos y la documentación del modo normal.
- Conserva Ultra Focus activado por defecto para no rebajar la protección existente.

## [1.2.0] - 2026-08-17

- Bloqueo continuo del volumen y mute mientras el modo biblioteca permanece activo.
- Detección local de actividad en la salida mediante la API pública Core Audio.
- Aviso visible ante actividad de audio o intentos de recuperar el volumen.
- Restauración reversible ampliada para salidas conectadas durante una sesión.
- Documentación clara sobre privacidad, compatibilidad y límites técnicos.

## [1.1.0] - 2026-08-17

- Rediseño compacto de 468 × 500 puntos, sin desplazamiento y con material translúcido nativo.
- Activación estricta de App Sandbox con privilegios mínimos.
- Sustitución de AppleScript por la API pública Core Audio.
- Eliminación de `pmset`, procesos externos y solicitudes de administrador.
- Integración opcional con Atajos mediante el esquema oficial `shortcuts://`.
- Verificación automática del entitlement de sandbox en CI.

Este proyecto sigue [Semantic Versioning](https://semver.org/lang/es/).

## [1.0.0] — 2026-08-17

### Añadido

- Modo biblioteca reversible con un solo botón.
- Silenciado de salida de audio y sonidos de alerta.
- Perfil energético orientado a reducir actividad, calor y ruido potencial.
- Integración opcional con No molestar mediante Atajos de macOS.
- Acceso rápido desde la barra de menús.
- Compatibilidad universal con Apple Silicon e Intel.
- Pruebas automatizadas para el análisis y la restauración del perfil energético.
