<div align="center">
  <img src="docs/images/app-icon.png" width="140" alt="Icono de Psst">

  # Psst — Mac Silence

  ### El silencio que tú eliges 🤫

  **Menos interrupciones, menos ruido, cero configuración complicada.**

  [![macOS CI](https://github.com/Fernando-Marcos/psst-mac-silence/actions/workflows/ci.yml/badge.svg)](https://github.com/Fernando-Marcos/psst-mac-silence/actions/workflows/ci.yml)
  [![Última versión](https://img.shields.io/github/v/release/Fernando-Marcos/psst-mac-silence?label=versi%C3%B3n&color=5AC8FA)](https://github.com/Fernando-Marcos/psst-mac-silence/releases/latest)
  [![Licencia MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](LICENSE)
  ![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
  ![App Sandbox](https://img.shields.io/badge/Apple-App%20Sandbox-success?logo=apple)

  ### [⬇️ Descargar la última versión](https://github.com/Fernando-Marcos/psst-mac-silence/releases/latest)

  [Cómo funciona](#los-tres-modos) · [Primeros pasos](#primeros-pasos) · [Preguntas frecuentes](#preguntas-frecuentes) · [Seguridad](#seguridad-apple-por-diseño)
</div>

<br>

Psst es una utilidad nativa, pequeña y transparente para preparar el Mac antes de estudiar, opositar o trabajar en un espacio silencioso. Elige entre tres modos: 🏛️ **biblioteca** silencia una vez y no vigila nada más, 🎧 **Concentración (Soft Mode)** silencia todo y pide permiso antes de dejar sonar música o vídeo, y 🛡️ **Ultra Focus (Hard Mode)** bloquea el audio sin excepciones hasta que desactives Psst. Al desactivarla, restaura siempre el estado anterior de tu audio, tal cual estaba.

<p align="center">
  <img src="docs/images/app-window-v1.4.0.png" width="460" alt="Ventana compacta y translúcida de Psst 1.4.0 con Concentración (Soft Mode) activado">
</p>

<div align="center">

🪟 Ventana nativa y translúcida &nbsp;•&nbsp; 🔒 App Sandbox, sin permisos raros &nbsp;•&nbsp; 🌐 Cero conexión a Internet &nbsp;•&nbsp; ↩️ Siempre reversible

</div>

## Instalación 📥

1. **Descarga** el ZIP universal desde [la última versión](https://github.com/Fernando-Marcos/psst-mac-silence/releases/latest): en *Assets*, al final de la página, es el único archivo `.zip`.
2. **Descomprímelo** (doble clic) y arrastra `Psst.app` a tu carpeta **Aplicaciones**.
3. **Ábrelo**: haz **clic derecho sobre `Psst.app` → Abrir** y confirma en el aviso. Solo hace falta la primera vez.

> 💬 **¿Por qué el clic derecho?** Psst se distribuye con firma *ad hoc* (gratuita, sin cuenta de desarrollador de Apple) en lugar de pasar por notarización. macOS avisa de que viene de un "desarrollador no identificado" aunque el código es público y auditable en este mismo repositorio. Si prefieres verificarlo tú mismo antes de abrirlo, tienes la sección [Compilar desde el código fuente](#compilar-desde-el-código-fuente).
>
> Si macOS bloquea la apertura del todo, ve a **Ajustes del Sistema → Privacidad y seguridad** y pulsa **Abrir de todos modos** junto al aviso sobre Psst.

No pide contraseña de administrador, cuenta ni conexión a Internet. Es un único binario universal (Apple Silicon e Intel) sin dependencias que instalar. ✅

## Primeros pasos 🚀

1. Abre Psst desde **Aplicaciones** o la barra de menús (el icono de altavoz).
2. Elige el modo antes de activar: dos interruptores debajo del botón principal, **Ultra Focus** y **Concentración**. Si dejas ambos apagados, se activa el modo biblioteca. Solo puedes cambiarlos con Psst inactivo.
3. Pulsa el botón grande **ACTIVAR**. Psst guarda tu volumen actual y silencia el equipo al instante.
4. Cuando termines, pulsa **DESACTIVAR**. Psst restaura exactamente el volumen y el estado de silencio que tenías antes de activarla.

💡 Si cierras Psst por error mientras está activa, al volver a abrirla retoma la vigilancia donde la dejaste sin perder tu configuración original.

## Los tres modos 🎚️

| Modo | Qué hace | Cuándo usarlo |
| --- | --- | --- |
| 🏛️ **Biblioteca** | Silencia el equipo una vez al activarse. Sin vigilancia continua. | Silencio puntual y reversible, sin más. |
| 🎧 **Concentración** (Soft Mode) | Silencia todo y vigila el audio; si detecta un intento de reproducir sonido, pregunta antes de dejarlo sonar. | Estudiar o trabajar escuchando música o un podcast con auriculares. |
| 🛡️ **Ultra Focus** (Hard Mode) | Silencia todo y bloquea sin preguntar cualquier intento de recuperar el sonido. | Máxima protección contra ruido accidental en espacios compartidos. |

Los tres modos son excluyentes entre sí y solo pueden cambiarse con Psst inactivo.

<details>
<summary><strong>🎧 Concentración (Soft Mode) en detalle</strong></summary>
<br>

- Al activar Psst, silencia todas las salidas compatibles, igual que el modo biblioteca.
- Comprueba la actividad de audio cada 400 ms, igual que Ultra Focus.
- Cuando detecta un intento de reproducir sonido, lo mantiene en silencio y muestra un aviso pidiendo permiso antes de que se oiga nada.
- Si lo permites, Psst restaura el audio y deja de vigilarlo hasta que desactives la app; si eliges mantener el silencio, sigue bloqueando futuros intentos como Ultra Focus.

</details>

<details>
<summary><strong>🛡️ Ultra Focus (Hard Mode) en detalle</strong></summary>
<br>

- Comprueba cada 400 ms que volumen y mute continúan protegidos.
- Vuelve a silenciar cualquier salida compatible que recupere el sonido, sin pedir confirmación.
- Muestra un aviso visible sin identificar ni inspeccionar la aplicación que reproduce audio.
- Aparece activado por defecto para conservar la protección de versiones anteriores.

</details>

## Por qué instalar Psst 💡

### Para estudiantes 🎓

- Ultra Focus evita que Spotify, un vídeo, una web o una alerta recuperen el sonido por accidente en clase o en la biblioteca.
- Concentración te deja estudiar con música o un podcast con cascos: silencia el resto y solo pide permiso cuando detecta un intento de reproducir sonido.
- Convierte el inicio de una sesión de estudio en un ritual inmediato y fácil de recordar.
- Ocupa poco espacio, permanece accesible en la barra de menús y no añade distracciones.

### Para opositores 📚

- Reduce pasos repetitivos antes de cada bloque largo de estudio.
- Restaura el audio previo al terminar, sin obligarte a recordar cómo estaba configurado.

### Para bibliotecas y espacios compartidos 🏛️

- El modo biblioteca aplica un silencio reversible sin vigilancia continua.
- Ultra Focus mantiene silenciadas las salidas compatibles mediante Core Audio durante toda la sesión.
- Concentración silencia el equipo pero permite escuchar música o vídeo con auriculares tras confirmarlo en un aviso.
- Ayuda a evitar interrupciones involuntarias sin tocar el control térmico del equipo.
- No necesita contraseña de administrador, cuenta, Internet ni procesos en segundo plano fuera de la app.

## Diseño compacto y nativo 🪟

La ventana fija mide 468 × 500 puntos con el marco de macOS: es prácticamente cuadrada y no tiene desplazamiento. Usa materiales translúcidos de AppKit para integrarse con el escritorio y respeta Reducir transparencia de macOS. Psst también está disponible desde la barra de menús.

## Seguridad Apple por diseño 🔒

- **App Sandbox activo** con un único entitlement: `com.apple.security.app-sandbox`.
- **Sin privilegios de administrador**, AppleScript, Apple Events, comandos de shell o procesos auxiliares.
- **Sin acceso** a red, cámara, micrófono, contactos ni archivos elegidos por el usuario.
- Audio controlado con la API pública **Core Audio**.
- Estado reversible guardado exclusivamente en el contenedor privado de la app.

Psst bloquea el **sonido audible** de la salida predeterminada compatible. Por seguridad y privacidad no inspecciona ni controla el reproductor de Spotify, el navegador o una app de vídeo: su reproducción puede avanzar sin que se oiga nada. Algunas salidas digitales o externas que no permiten volumen o mute por software quedan fuera del control de cualquier app sandboxed; Psst lo comunica si no puede silenciarlas.

La configuración cumple la base técnica del sandbox exigido por Apple. Una publicación en Mac App Store todavía requiere firma de distribución, perfil, ficha de App Store Connect y revisión de Apple.

## Ventiladores y bajo consumo 🌬️

Psst no baja directamente las revoluciones de los ventiladores. Apple no publica una API para ello, y forzar menos refrigeración podría sobrecalentar el Mac. macOS conserva siempre el control térmico y decide cuándo activar el Bajo consumo.

## Preguntas frecuentes ❓

<details>
<summary><strong>¿Por qué macOS dice que Psst es de un "desarrollador no identificado"?</strong></summary>
<br>

Porque se distribuye con firma ad hoc en lugar de pasar por la notarización de pago de Apple. El código fuente es público: puedes revisarlo o compilarlo tú mismo (ver [Compilar desde el código fuente](#compilar-desde-el-código-fuente)) antes de confiar en el binario descargado.
</details>

<details>
<summary><strong>¿Psst escucha o graba lo que reproduzco?</strong></summary>
<br>

No. Solo consulta si hay actividad de audio y el nivel de volumen/mute mediante Core Audio; nunca accede a las muestras de sonido ni sabe qué app o contenido las genera.
</details>

<details>
<summary><strong>¿Funciona con AirPods u otros auriculares Bluetooth?</strong></summary>
<br>

Sí, siempre que el dispositivo exponga control de volumen o mute por software. Algunas salidas digitales o externas no lo permiten; en ese caso Psst te lo indica en pantalla en lugar de fingir que las ha silenciado.
</details>

<details>
<summary><strong>¿Qué pasa si el Mac se reinicia o cierro Psst a la fuerza mientras está activa?</strong></summary>
<br>

Al volver a abrirla, si sigue marcada como activa, retoma la vigilancia y mantiene el silencio sin pedirte nada. Tu configuración de audio original queda guardada hasta que la desactives.
</details>

<details>
<summary><strong>¿Baja las revoluciones del ventilador o el consumo?</strong></summary>
<br>

No de forma directa: consulta la sección [Ventiladores y bajo consumo](#ventiladores-y-bajo-consumo).
</details>

## Compilar desde el código fuente 🛠️

Necesitas macOS 13 o posterior y las Command Line Tools de Apple.

```bash
git clone https://github.com/Fernando-Marcos/psst-mac-silence.git
cd psst-mac-silence
./Scripts/test.sh
./Scripts/build-app.sh
codesign -dvvv --entitlements - build/Psst.app
open build/Psst.app
```

El binario generado es universal para Apple Silicon e Intel. La integración continua valida pruebas, firma, sandbox y ambas arquitecturas en cada cambio.

## Documentación 📚

- [Arquitectura y decisiones de seguridad](docs/ARCHITECTURE.md)
- [Privacidad](PRIVACY.md)
- [Política de seguridad](SECURITY.md)
- [Cómo contribuir](CONTRIBUTING.md)
- [Historial de cambios](CHANGELOG.md)

## Licencia 📄

Psst se distribuye bajo la [licencia MIT](LICENSE).

<div align="center">

<sub>Hecho con 🤫 por <a href="https://github.com/Fernando-Marcos">Fernando Marcos</a></sub>

</div>
