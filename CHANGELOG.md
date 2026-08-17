# Historial de cambios

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
