import SwiftUI

/// A thumbnail for a bike ride.
struct RideThumbnail {
    let lightImage: UIImage
    let darkImage: UIImage

    func image(for colorScheme: ColorScheme) -> UIImage {
        switch colorScheme {
        case .light:
            lightImage
        case .dark:
            darkImage
        @unknown default:
            lightImage
        }
    }
}
