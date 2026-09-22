import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers
let space = CGColorSpace(name: CGColorSpace.sRGB)!
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor {
    CGColor(colorSpace: space, components: [r/255,g/255,b/255,1])!
}
context.setFillColor(color(10,10,10)); context.fill(CGRect(x: 0,y: 0,width: 1024,height: 1024))
let font = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, 720, nil)
let text = NSAttributedString(string: "C/", attributes: [
    NSAttributedString.Key(kCTFontAttributeName as String): font,
    NSAttributedString.Key(kCTForegroundColorAttributeName as String): color(244,244,239),
    NSAttributedString.Key(kCTKernAttributeName as String): -60
])
let line = CTLineCreateWithAttributedString(text)
let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
context.textPosition = CGPoint(x: (1024-bounds.width)/2-bounds.minX, y: 350-bounds.minY)
CTLineDraw(line, context)
context.setFillColor(color(255,92,41)); context.fill(CGRect(x: 160,y: 210,width: 704,height: 26))
let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, context.makeImage()!, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Could not export app icon") }
