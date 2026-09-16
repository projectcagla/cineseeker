import AppKit
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()
NSColor(calibratedWhite: 0.04, alpha: 1).setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
let ring = NSBezierPath()
ring.appendArc(withCenter: NSPoint(x: 496, y: 540), radius: 278, startAngle: 42, endAngle: 318, clockwise: false)
ring.lineWidth = 76; ring.lineCapStyle = .round
NSColor(calibratedRed: 1, green: 0.46, blue: 0.12, alpha: 1).setStroke(); ring.stroke()
let play = NSBezierPath(); play.move(to: NSPoint(x: 440, y: 384)); play.line(to: NSPoint(x: 440, y: 696)); play.line(to: NSPoint(x: 672, y: 540)); play.close()
NSGradient(starting: NSColor(calibratedRed: 1, green: 0.42, blue: 0.1, alpha: 1), ending: NSColor(calibratedRed: 1, green: 0.77, blue: 0.24, alpha: 1))!.draw(in: play, angle: 60)
let sparkle = NSBezierPath(); sparkle.move(to: NSPoint(x: 782,y: 765)); sparkle.line(to: NSPoint(x: 802,y: 812)); sparkle.line(to: NSPoint(x: 848,y: 832)); sparkle.line(to: NSPoint(x: 802,y: 852)); sparkle.line(to: NSPoint(x: 782,y: 899)); sparkle.line(to: NSPoint(x: 762,y: 852)); sparkle.line(to: NSPoint(x: 715,y: 832)); sparkle.line(to: NSPoint(x: 762,y: 812)); sparkle.close()
NSColor(calibratedRed: 1, green: 0.77, blue: 0.3, alpha: 1).setFill(); sparkle.fill()
image.unlockFocus()
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
image.draw(in: NSRect(origin: .zero,size: size)); NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
