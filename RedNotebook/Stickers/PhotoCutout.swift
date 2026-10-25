import CoreImage
import UIKit
import Vision

/// Turns a photo into a sticker by lifting the subject out of the background, like long-pressing a photo in iOS.
enum PhotoCutout {
    /// Returns transparent PNG data, or the whole (downscaled) photo if no subject was found.
    static func makeSticker(from data: Data) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: data)?.downscaled(maxSide: 1024),
                  let cgImage = image.cgImage else { return nil }
            if let cutout = liftSubject(from: cgImage) {
                return UIImage(cgImage: cutout).pngData()
            }
            return image.pngData()
        }.value
    }

    private static func liftSubject(from cgImage: CGImage) -> CGImage? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            guard let result = request.results?.first else { return nil }
            let buffer = try result.generateMaskedImage(ofInstances: result.allInstances, from: handler,
                                                        croppedToInstancesExtent: true)
            let image = CIImage(cvPixelBuffer: buffer)
            return CIContext().createCGImage(image, from: image.extent)
        } catch {
            return nil
        }
    }
}

private extension UIImage {
    /// Redraws the image upright (photos often carry a rotation flag) and no larger than `maxSide`.
    func downscaled(maxSide: CGFloat) -> UIImage {
        let factor = min(1, maxSide / max(size.width, size.height))
        let target = CGSize(width: (size.width * factor).rounded(), height: (size.height * factor).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
