#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
SOURCE_ICON="$PROJECT_DIR/docs/images/app-icon.png"
BUILD_DIR="$PROJECT_DIR/build"
ICONSET="$BUILD_DIR/AppIcon.iconset"

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "No se encuentra el icono fuente en $SOURCE_ICON" >&2
  exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

sizes=(16 32 128 256 512)
for size in "${sizes[@]}"; do
  double=$((size * 2))
  sips -z "$size" "$size" "$SOURCE_ICON" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  sips -z "$double" "$double" "$SOURCE_ICON" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o "$PROJECT_DIR/Resources/AppIcon.icns"
echo "$PROJECT_DIR/Resources/AppIcon.icns"
