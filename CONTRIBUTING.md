# Contribuir a Psst

Gracias por ayudar a mejorar Psst. Las contribuciones deben mantener tres principios: seguridad térmica, reversibilidad y privacidad local.

## Preparar el proyecto

Necesitas macOS 13 o posterior, Git y las Command Line Tools de Apple.

```bash
git clone https://github.com/Fernando-Marcos/psst-mac-silence.git
cd psst-mac-silence
./Scripts/test.sh
./Scripts/build-app.sh
```

## Proponer un cambio

1. Abre una incidencia que describa el problema o la mejora.
2. Crea una rama pequeña y centrada en un único objetivo.
3. Añade pruebas cuando cambie la lógica que analiza o restaura ajustes.
4. Ejecuta `./Scripts/test.sh` y `./Scripts/build-app.sh`.
5. Abre un pull request explicando el comportamiento anterior, el nuevo y cómo lo verificaste.

## Límites de seguridad

No se aceptarán cambios que:

- Fuercen los ventiladores por debajo de los mínimos definidos por Apple.
- Manipulen directamente el SMC o desactiven protecciones térmicas.
- Guarden contraseñas o eludan el diálogo de autorización de macOS.
- Añadan analítica, seguimiento o conexiones de red sin una discusión pública previa.
- Impidan restaurar de forma fiable los ajustes anteriores.
