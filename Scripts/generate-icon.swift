import AppKit

let project = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconset = project.appendingPathComponent("build/AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

let specifications: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)
]

for spec in specifications {
    let size = CGFloat(spec.pixels)
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let bounds = NSRect(x: 0, y: 0, width: size, height: size)
    let inset = size * 0.035
    let shape = NSBezierPath(roundedRect: bounds.insetBy(dx: inset, dy: inset), xRadius: size * 0.23, yRadius: size * 0.23)
    NSGradient(colors: [
        NSColor(red: 0.04, green: 0.34, blue: 0.36, alpha: 1),
        NSColor(red: 0.05, green: 0.10, blue: 0.19, alpha: 1)
    ])?.draw(in: shape, angle: -45)

    if let symbol = NSImage(systemSymbolName: "speaker.slash.fill", accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: size * 0.48, weight: .semibold)
        let configured = symbol.withSymbolConfiguration(config) ?? symbol
        configured.isTemplate = true
        let symbolSize = configured.size
        let target = NSRect(
            x: (size - symbolSize.width) / 2,
            y: (size - symbolSize.height) / 2,
            width: symbolSize.width,
            height: symbolSize.height
        )
        NSColor.white.set()
        configured.draw(in: target, from: .zero, operation: .sourceOver, fraction: 1)
    }

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("No se pudo generar \(spec.name)")
    }
    try png.write(to: iconset.appendingPathComponent(spec.name))
}

print(iconset.path)
