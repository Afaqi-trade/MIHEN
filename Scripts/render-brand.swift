import AppKit
import Foundation

// The full-bleed master is the source of the app icon and in-app brand mark.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let master = root.appendingPathComponent("Design/MihenIconMaster.png")
let assets = root.appendingPathComponent("MIHEN/Assets.xcassets")
guard let source = NSImage(contentsOf: master) else { fatalError("Missing icon master") }
func render(_ path: String, size: Int) throws {
    guard let image = source.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let graphics = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
            bytesPerRow: size * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { fatalError("Cannot create icon bitmap") }
    graphics.interpolationQuality = .high
    graphics.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
    guard let output = graphics.makeImage() else { fatalError("Cannot render icon") }
    let bitmap = NSBitmapImageRep(cgImage: output)
    guard let bytes = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot encode icon") }
    try bytes.write(to: assets.appendingPathComponent(path))
}
try render("AppIcon.appiconset/AppIcon.png", size: 1024)
try render("BrandMark.imageset/BrandMark.png", size: 512)
