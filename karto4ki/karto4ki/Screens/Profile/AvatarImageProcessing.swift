import UIKit

enum AvatarImageProcessing {

    /// Подготовка квадратного аватара к загрузке: масштаб и JPEG.
    static func jpegDataForUpload(fromSquareImage image: UIImage) -> Data? {
        let side: CGFloat = 512
        let scaled = resizeIfNeeded(image: image, maxSide: side)
        // TODO: update compression
        return scaled.jpegData(compressionQuality: 0.82)
    }

    static func resizeIfNeeded(image: UIImage, maxSide: CGFloat) -> UIImage {
        let w = image.size.width
        let h = image.size.height
        let longest = max(w, h)
        guard longest > maxSide else { return image }
        let scale = maxSide / longest
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    static func normalizedUpOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
