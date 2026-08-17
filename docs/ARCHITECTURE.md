# Arquitectura y decisiones de seguridad

Psst es una aplicación SwiftUI nativa para macOS. Su diseño mantiene separadas la interfaz, la coordinación del modo biblioteca y las operaciones del sistema.

## Componentes

- `PsstApp.swift`: ciclo de vida, ventana principal y menú de la barra de menús.
- `ContentView.swift`: interfaz y explicación visible del estado activo.
- `SilenceController.swift`: activación, restauración y manejo de errores.
- `SystemServices.swift`: audio, energía, Atajos y persistencia local.
- `Models.swift`: instantánea reversible y modelos de estado.

## Flujo de activación

1. Lee el estado actual del audio y del perfil energético.
2. Guarda una instantánea local antes de realizar cambios.
3. Silencia la salida y las alertas.
4. Solicita a macOS autorización para aplicar los ajustes energéticos.
5. Ejecuta el atajo opcional que activa No molestar.

La desactivación aplica el recorrido inverso y elimina la instantánea cuando la restauración termina correctamente.

## Por qué no controla directamente los ventiladores

El controlador térmico necesita reaccionar a la temperatura real de cada componente. Reducir artificialmente las revoluciones puede elevar la temperatura, provocar limitación de rendimiento y comprometer la vida útil del equipo.

Psst utiliza únicamente mecanismos de macOS para reducir actividad y consumo. Así disminuye la causa del ruido sin interferir en la respuesta automática de refrigeración de Apple.

## Privacidad y privilegios

No existe backend ni tráfico de red. La instantánea se guarda localmente y contiene solo valores de configuración necesarios para restaurar el estado anterior. Las operaciones privilegiadas pasan por el diálogo de autorización de macOS; la app nunca recibe la contraseña.
