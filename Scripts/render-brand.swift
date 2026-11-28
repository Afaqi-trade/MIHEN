import AppKit
import Foundation
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("MIHEN/Assets.xcassets")
func render(name: String, size: Int, dark: Bool = false, tinted: Bool = false) throws {
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.scaleBy(x: CGFloat(size) / 1000, y: CGFloat(size) / 1000)
    func color(_ hex: Int) -> CGColor { CGColor(red: CGFloat((hex >> 16) & 255)/255, green: CGFloat((hex >> 8) & 255)/255, blue: CGFloat(hex & 255)/255, alpha: 1) }
    context.setFillColor(color(tinted ? 0x111111 : dark ? 0x071D2C : 0x0C3440)); context.fill(CGRect(x: 0, y: 0, width: 1000, height: 1000))
    func polygon(_ points: [CGPoint], fill: Int) {
        let path = CGMutablePath(); path.addLines(between: points); path.closeSubpath()
        context.addPath(path); context.setFillColor(color(fill)); context.fillPath()
    }
    polygon([CGPoint(x: 155,y:275), CGPoint(x: 365,y:690), CGPoint(x: 465,y:545), CGPoint(x: 575,y:750), CGPoint(x: 845,y:275)], fill: tinted ? 0xE7E7E7 : 0xF2F1E8)
    polygon([CGPoint(x: 155,y:275), CGPoint(x: 365,y:355), CGPoint(x: 590,y:290), CGPoint(x: 845,y:275), CGPoint(x: 845,y:205), CGPoint(x:155,y:205)], fill: tinted ? 0xBBBBBB : 0x73B991)
    let road = CGMutablePath()
    road.move(to: CGPoint(x: 415,y:205)); road.addCurve(to: CGPoint(x: 560,y:420), control1: CGPoint(x: 630,y:300), control2: CGPoint(x: 395,y:300)); road.addCurve(to: CGPoint(x: 575,y:670), control1: CGPoint(x: 650,y:530), control2: CGPoint(x: 520,y:590))
    context.addPath(road); context.setStrokeColor(color(tinted ? 0x111111 : dark ? 0x071D2C : 0x0C3440)); context.setLineWidth(38); context.setLineCap(.round); context.strokePath()
    context.setFillColor(color(tinted ? 0xFFFFFF : 0xE5C77A)); context.fillEllipse(in: CGRect(x: 647,y:744,width:62,height:62))
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
