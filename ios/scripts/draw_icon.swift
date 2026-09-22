import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
// Run from the repository root. All surfaces share public/brand/geometry.json.
let commands = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: "public/brand/geometry.json"))) as! [[Any]]
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor {
    CGColor(colorSpace: space, components: [r/255, g/255, b/255, 1])!
}
context.setFillColor(color(10, 10, 10))
context.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
context.translateBy(x: 12, y: 1032)
context.scaleBy(x: 10, y: -10)
for command in commands {
    func point(_ index: Int) -> CGPoint { CGPoint(x: command[index] as! Double, y: command[index + 1] as! Double) }
    switch command[0] as! String {
    case "M": context.move(to: point(1))
    case "L": context.addLine(to: point(1))
    case "C": context.addCurve(to: point(5), control1: point(1), control2: point(3))
    default: break
    }
}
context.closePath()
context.setFillColor(color(255, 133, 52))
context.fillPath()
let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, context.makeImage()!, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Could not export app icon") }
