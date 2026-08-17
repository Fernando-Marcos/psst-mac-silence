<div align="center">
  <img src="docs/images/app-icon.png" width="160" alt="Icono de Psst">

  # Psst — Mac Silence

  **Modo biblioteca para macOS: menos interrupciones, menos calor y menos ruido.**

  [![macOS CI](https://github.com/Fernando-Marcos/psst-mac-silence/actions/workflows/ci.yml/badge.svg)](https://github.com/Fernando-Marcos/psst-mac-silence/actions/workflows/ci.yml)
  [![Última versión](https://img.shields.io/github/v/release/Fernando-Marcos/psst-mac-silence?label=versi%C3%B3n)](https://github.com/Fernando-Marcos/psst-mac-silence/releases/latest)
  [![Licencia MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](LICENSE)
  ![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
</div>

Psst es una app nativa y ligera que prepara el Mac para estudiar, concentrarse o trabajar en espacios silenciosos. Con un solo botón silencia el audio, aplica un perfil energético más eficiente y, si lo configuras, activa **No molestar**. Al terminar, restaura los ajustes que tenías antes.

## Por qué merece la pena instalarla

### Si eres estudiante

- Evita que un vídeo, una web o una alerta suenen por accidente en clase o en la biblioteca.
- Reduce las interrupciones y ayuda a convertir el inicio de una sesión de estudio en un hábito sencillo.
- Favorece un funcionamiento más fresco cuando solo necesitas apuntes, navegador, PDF o procesador de texto.

### Si estás preparando una oposición

- Permite empezar bloques largos de estudio sin revisar varios ajustes del sistema cada vez.
- Reduce la tentación de atender notificaciones si se combina con el modo de concentración de macOS.
- Conserva y restaura tu configuración anterior, para que puedas volver a usar el Mac normalmente al finalizar.

### Si trabajas en bibliotecas o espacios compartidos

- Silencia tanto la salida de audio como las alertas del sistema.
- Disminuye actividad energética innecesaria y la generación de calor, reduciendo la probabilidad de que los ventiladores tengan que acelerarse.
- Funciona desde la ventana principal o discretamente desde la barra de menús.

## Qué hace

- Silencia el volumen de salida y los sonidos de alerta.
- Activa temporalmente el modo de bajo consumo y ajusta opciones de reposo compatibles.
- Ejecuta dos atajos opcionales para activar y desactivar **No molestar**.
- Guarda el estado previo y lo restaura al salir del modo biblioteca.
- Trabaja localmente, sin cuentas, anuncios, analítica ni conexión a servidores.
- Incluye binario universal para Macs con Apple Silicon e Intel.

## Seguridad térmica: silencio sin poner en riesgo el Mac

Psst **no fuerza los ventiladores por debajo de la velocidad mínima segura**. macOS no ofrece una API pública para hacerlo y anular la refrigeración automática podría provocar sobrecalentamiento, pérdida de rendimiento o daños.

La app actúa sobre la causa habitual del ruido: reduce consumo, actividad y calor para que el propio sistema necesite menos ventilación. macOS mantiene en todo momento el control térmico y puede acelerar los ventiladores si es necesario.

## Instalación

1. Descarga `Psst-1.0.0-macOS-universal.zip` desde [la última versión](https://github.com/Fernando-Marcos/psst-mac-silence/releases/latest).
2. Descomprime el archivo y mueve `Psst.app` a **Aplicaciones**.
3. En el primer inicio, haz clic derecho sobre la app y selecciona **Abrir** si macOS muestra el aviso de desarrollador no identificado.

La primera activación solicita autorización de administrador para cambiar temporalmente el perfil energético. La contraseña se escribe en el diálogo seguro de macOS: Psst no puede verla ni guardarla.

## Activar también No molestar

Apple no proporciona una API pública estable para cambiar los modos de concentración desde una app independiente. Psst usa la integración oficial con **Atajos**:

1. Crea en la app **Atajos** un atajo llamado `Psst Activar biblioteca` que active No molestar.
2. Crea otro llamado `Psst Desactivar biblioteca` que lo desactive.

Psst los detectará y ejecutará automáticamente. El resto de funciones no depende de estos atajos.

## Compilar desde el código fuente

Necesitas macOS 13 o posterior y las Command Line Tools de Apple.

```bash
git clone https://github.com/Fernando-Marcos/psst-mac-silence.git
cd psst-mac-silence
./Scripts/test.sh
./Scripts/build-app.sh
open build/Psst.app
```

El repositorio incluye `Package.swift` para trabajar cómodamente desde Xcode. El script de compilación genera directamente un paquete universal y no depende de SwiftPM.

## Documentación

- [Arquitectura y decisiones de seguridad](docs/ARCHITECTURE.md)
- [Privacidad](PRIVACY.md)
- [Política de seguridad](SECURITY.md)
- [Cómo contribuir](CONTRIBUTING.md)
- [Historial de cambios](CHANGELOG.md)

## Licencia

Psst se distribuye bajo la [licencia MIT](LICENSE).
