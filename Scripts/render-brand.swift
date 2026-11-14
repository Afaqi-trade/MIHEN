import AppKit
import Foundation
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("MIHEN/Assets.xcassets")
func render(name: String, size: Int, dark: Bool = false, tinted: Bool = false) throws {
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.scaleBy(x: CGFloat(size) / 1000, y: CGFloat(size) / 1000)
    func color(_ hex: Int) -> CGColor { CGColor(red: CGFloat((hex >> 16) & 255)/255, green: CGFloat((hex >> 8) & 255)/255, blue: CGFloat(hex & 255)/255, alpha: 1) }
    context.setFillColor(color(dark ? 0x06152C : tinted ? 0x222222 : 0xF7F5EF)); context.fill(CGRect(x: 0, y: 0, width: 1000, height: 1000))
    func polygon(_ points: [CGPoint], fill: Int) {
        let path = CGMutablePath(); path.addLines(between: points); path.closeSubpath()
        context.addPath(path); context.setFillColor(color(fill)); context.fillPath()
    }
    polygon([CGPoint(x: 120,y:260), CGPoint(x: 350,y:700), CGPoint(x: 490,y:500), CGPoint(x: 635,y:790), CGPoint(x: 900,y:260)], fill: dark || tinted ? 0xF7F5EF : 0x0B2244)
    polygon([CGPoint(x: 120,y:260), CGPoint(x: 400,y:320), CGPoint(x: 650,y:235), CGPoint(x: 900,y:260), CGPoint(x: 900,y:170), CGPoint(x:120,y:170)], fill: tinted ? 0xAAAAAA : 0x168B49)
    let road = CGMutablePath()
    road.move(to: CGPoint(x: 440,y:170)); road.addCurve(to: CGPoint(x: 590,y:450), control1: CGPoint(x: 700,y:280), control2: CGPoint(x: 310,y:290)); road.addCurve(to: CGPoint(x: 635,y:720), control1: CGPoint(x: 730,y:580), control2: CGPoint(x: 570,y:600))
    context.addPath(road); context.setStrokeColor(color(dark || tinted ? 0x0B2244 : 0xF7F5EF)); context.setLineWidth(45); context.setLineCap(.round); context.strokePath()
    context.setFillColor(color(tinted ? 0xDDDDDD : 0xE53935)); context.fillEllipse(in: CGRect(x: 690,y:790,width:75,height:75))
    let image = context.makeImage()!
    let representation = NSBitmapImageRep(cgImage: image)
    let bytes = representation.representation(using: .png, properties: [:])!
    let path = assets.appendingPathComponent(name)
    try FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
    try bytes.write(to: path)
}
try render(name: "AppIcon.appiconset/AppIcon.png", size: 1024)
try render(name: "AppIcon.appiconset/AppIcon-dark.png", size: 1024, dark: true)
try render(name: "AppIcon.appiconset/AppIcon-tinted.png", size: 1024, tinted: true)
try render(name: "BrandMark.imageset/BrandMark.png", size: 512)
