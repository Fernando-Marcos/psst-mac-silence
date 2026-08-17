#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
BUILD_DIR="$PROJECT_DIR/build"
APP_DIR="$BUILD_DIR/Psst.app"
ARCH_DIR="$BUILD_DIR/architectures"

cd "$PROJECT_DIR"
mkdir -p "$ARCH_DIR"

COMMON_FLAGS=(-swift-version 5 -parse-as-library -O -framework SwiftUI -framework AppKit)
swiftc "${COMMON_FLAGS[@]}" -target x86_64-apple-macosx13.0 Sources/Psst/*.swift -o "$ARCH_DIR/Psst-x86_64"
swiftc "${COMMON_FLAGS[@]}" -target arm64-apple-macosx13.0 Sources/Psst/*.swift -o "$ARCH_DIR/Psst-arm64"
lipo -create "$ARCH_DIR/Psst-x86_64" "$ARCH_DIR/Psst-arm64" -output "$ARCH_DIR/Psst"

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$ARCH_DIR/Psst" "$APP_DIR/Contents/MacOS/Psst"
cp "$PROJECT_DIR/Resources/Info.plist" "$APP_DIR/Contents/Info.plist"

if [[ -f "$PROJECT_DIR/Resources/AppIcon.icns" ]]; then
  cp "$PROJECT_DIR/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

codesign --force --deep --sign - "$APP_DIR"
echo "$APP_DIR"
