import Bike
import SwiftUI

/// A thumbnail for a bike ride.
struct RideThumbnail {
    let lightImage: OSImage
    let darkImage: OSImage

    func image(for colorScheme: ColorScheme) -> OSImage {
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
