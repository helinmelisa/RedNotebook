import AppKit

// Draws the Red Notebook app icon: red leather cover, stitching, elastic band and debossed "HME".
let size = 1024.0
// Opaque bitmap (App Store icons can't have transparency)
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

// Leather gradient
// Cover colour from the command line (base r g b, 0–1), red by default. Matches CoverColor in the app:
// light = 15% towards white, dark = 42% towards black.
let args = CommandLine.arguments
let base = args.count >= 5 ? (Double(args[2])!, Double(args[3])!, Double(args[4])!) : (0.72, 0.09, 0.11)
func mix(_ c: (Double, Double, Double), _ t: (Double, Double, Double), _ amount: Double) -> NSColor {
    NSColor(red: c.0 + (t.0 - c.0) * amount, green: c.1 + (t.1 - c.1) * amount, blue: c.2 + (t.2 - c.2) * amount, alpha: 1)
}
let colors = [mix(base, (1, 1, 1), 0.15).cgColor,
              mix(base, base, 0).cgColor,
              mix(base, (0, 0, 0), 0.42).cgColor] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.5, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])

// Grain
srand48(42)
for _ in 0..<26000 {
    let x = drand48() * size, y = drand48() * size, r = 0.8 + drand48() * 2.2
    let light = drand48() > 0.5
    ctx.setFillColor(light ? NSColor(white: 1, alpha: 0.05).cgColor : NSColor(white: 0, alpha: 0.09).cgColor)
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r))
}

// Spine shadow on the left
let spine = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [NSColor(white: 0, alpha: 0.35).cgColor, NSColor(white: 0, alpha: 0).cgColor] as CFArray,
                       locations: [0, 1])!
ctx.drawLinearGradient(spine, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 110, y: 0), options: [])

// Stitching
ctx.setStrokeColor(NSColor(red: 0.96, green: 0.82, blue: 0.72, alpha: 0.8).cgColor)
ctx.setLineWidth(7)
ctx.setLineDash(phase: 0, lengths: [26, 17])
ctx.addPath(CGPath(roundedRect: CGRect(x: 78, y: 78, width: size - 156, height: size - 156), cornerWidth: 160, cornerHeight: 160, transform: nil))
ctx.strokePath()
ctx.setLineDash(phase: 0, lengths: [])

// Elastic band
let bandX = size - 210.0
let band = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                      colors: [NSColor(white: 0.10, alpha: 1).cgColor, NSColor(white: 0.26, alpha: 1).cgColor,
                               NSColor(white: 0.08, alpha: 1).cgColor] as CFArray,
                      locations: [0, 0.45, 1])!
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: -6, height: 0), blur: 14, color: NSColor(white: 0, alpha: 0.5).cgColor)
ctx.addRect(CGRect(x: bandX, y: 0, width: 64, height: size))
ctx.clip()
ctx.drawLinearGradient(band, start: CGPoint(x: bandX, y: 0), end: CGPoint(x: bandX + 64, y: 0), options: [])
ctx.restoreGState()

// Debossed title: light edge below-right, dark edge above-left, then the pressed-in fill
func drawTitle(_ color: NSColor, dx: CGFloat, dy: CGFloat) {
    let font = NSFont(name: "Georgia-Bold", size: 190) ?? NSFont.boldSystemFont(ofSize: 190)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .kern: 16]
    let text = NSAttributedString(string: "HME", attributes: attrs)
    let bounds = text.size()
    let centerX = (bandX + 40) / 2
    text.draw(at: NSPoint(x: centerX - bounds.width / 2 + dx, y: size / 2 - bounds.height / 2 + 20 + dy))
}
drawTitle(NSColor(white: 1, alpha: 0.22), dx: 4, dy: -4)
drawTitle(NSColor(white: 0, alpha: 0.35), dx: -3, dy: 3)
drawTitle(mix(base, (0, 0, 0), 0.38), dx: 0, dy: 0)

NSGraphicsContext.current?.flushGraphics()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
