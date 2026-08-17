# Propósito

- Psst es una utilidad nativa de macOS (13+) que silencia de forma reversible las salidas de audio compatibles con tres modos mutuamente excluyentes: biblioteca (silencio simple, sin vigilancia), Concentración/Soft Mode (silencia todo y pide permiso mediante un aviso antes de dejar sonar música o vídeo) y Ultra Focus/Hard Mode (vigilancia cada 400 ms que corrige cualquier intento de recuperar volumen sin dar opción a permitirlo).
- Excelencia aquí significa: cero privilegios innecesarios, sandbox mínimo verificable, sin red ni recogida de datos, y comportamiento predecible al activar/desactivar (restaurar siempre el estado previo exacto).
- Prioriza seguridad y transparencia sobre funcionalidad añadida. Cualquier cambio que amplíe la superficie de privilegios (Process, AppleScript, Apple Events, red, acceso a archivos del usuario) requiere justificación explícita y probablemente rompe el modelo de seguridad documentado en `docs/ARCHITECTURE.md`.
- Publicado como binario universal (arm64 + x86_64) en GitHub Releases; no distribuido aún en Mac App Store (requeriría firma de distribución, perfil y revisión de Apple).

# Archivos

- `Sources/Psst/`: código fuente único y fuente de verdad.
  - `PsstApp.swift`: ciclo de vida, ventana fija (468×500pt), menú de barra de menús.
  - `ContentView.swift`: interfaz SwiftUI/AppKit con `NSVisualEffectView`.
  - `SilenceController.swift`: estado, `FocusMode` (biblioteca/soft/hard), vigilancia, avisos, restauración y persistencia.
  - `SystemServices.swift`: integración Core Audio (`AudioService`).
  - `Models.swift`: instantánea de audio y el enum `FocusMode`.
- `Resources/Psst.entitlements`: único entitlement permitido es `com.apple.security.app-sandbox`. No añadir entitlements sin actualizar `docs/ARCHITECTURE.md` y `PRIVACY.md`.
- `Resources/Info.plist`: metadatos del bundle de la app.
- `Tests/ModelSmoke.swift` y `Tests/PsstTests/`: pruebas de `FocusMode` y de la instantánea de audio (sin dependencias de UI).
- `Scripts/build-app.sh`: compila universal, empaqueta el `.app` y firma ad hoc (`codesign --sign -`).
- `Scripts/test.sh`: compila y ejecuta las pruebas de humo de `Models.swift`.
- `Scripts/generate-icon.swift`: genera el iconset desde símbolos SF Symbols.
- `docs/ARCHITECTURE.md`: decisiones de seguridad y flujo de activación/desactivación — consultar antes de tocar `SilenceController.swift` o `SystemServices.swift`.
- `docs/releases/vX.Y.Z.md` + `CHANGELOG.md`: historial de versiones; actualizar ambos en cada release.
- `.github/`: workflow de CI que valida build universal y entitlements incorporados a la firma.
- `PRIVACY.md` y `SECURITY.md`: compromisos públicos sobre privacidad y reporte de vulnerabilidades; cualquier cambio de comportamiento que los afecte debe reflejarse ahí.

# Orden de trabajo

1. Antes de tocar audio/sandbox, lee `docs/ARCHITECTURE.md` para no romper el modelo de privilegios ni el flujo de activación/restauración.
2. Cambios en `Sources/Psst/`, ejecuta `./Scripts/test.sh` (pruebas de modelos) antes de dar nada por terminado. Si tocas `SilenceController.swift`, verifica manualmente activar/desactivar y los tres modos (biblioteca, Concentración, Ultra Focus) en un Mac real — el comportamiento de Core Audio no es simulable en pruebas unitarias.
3. Para verificar el build completo: `./Scripts/build-app.sh` y luego `codesign -dvvv --entitlements - build/Psst.app` para confirmar que el entitlement sigue siendo únicamente `app-sandbox`.
4. Tras cada cambio que modifique `Sources/Psst/` y compile correctamente, sustituye la app instalada en `/Applications/Psst.app` por el build nuevo (cerrar la instancia en ejecución, borrar la anterior, copiar `build/Psst.app` y volver a abrirla) para que Fernando siempre pruebe la versión al día en su equipo.
5. Actualiza `CHANGELOG.md` y añade `docs/releases/vX.Y.Z.md` en cada cambio de versión visible al usuario; sigue el formato de los releases anteriores.
6. La CI de GitHub Actions valida build universal (arm64+x86_64) y entitlements en cada push — no la saltes ni la debilites.
7. No hagas commit, push, tag de release ni publicación de Release en GitHub sin confirmación explícita de Fernando para ese cambio concreto.
8. Antes de cualquier push, ejecuta Gitleaks con redacción total; este proyecto no debería tener secretos nunca (sin backend, sin red), así que cualquier hallazgo es señal de un error grave.
9. Proyecto clasificado como publicación en GitHub (repo público, releases, CI) pero sin despliegue en servidor propio — no aplica `production-deploy`/cPanel.

# Estilo Editorial

- Todo el contenido orientado al usuario (README, CHANGELOG, releases, UI, avisos en pantalla) va en español claro, directo y sin anglicismos innecesarios.
- Comentarios de código y nombres de símbolos en inglés, siguiendo las convenciones ya presentes en `Sources/Psst/`.
- La documentación de seguridad (`docs/ARCHITECTURE.md`, `PRIVACY.md`, `SECURITY.md`) debe ser precisa y verificable: no afirmar protecciones que el sandbox no garantiza, y explicitar límites conocidos (p. ej. salidas digitales sin control de volumen por software).
- Mensajes de commit y PR en español, imperativo, describiendo el efecto del cambio (ver histórico con `git log` para el tono ya establecido).
