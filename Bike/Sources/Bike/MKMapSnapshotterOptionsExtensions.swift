import MapKit
import SwiftUI

#if !os(watchOS)
public extension MKMapSnapshotter.Options {
    /// Convenience method to configure snapshotter options for light/dark mode, on iOS and macOS.
    func configure(for colorScheme: ColorScheme) {
        #if canImport(UIKit)
        let userInterfaceStyle: UIUserInterfaceStyle = switch colorScheme {
        case .light:
            .light
        case .dark:
            .dark
        @unknown default:
            .light
        }
        traitCollection = traitCollection.modifyingTraits { mutableTraits in
            mutableTraits.userInterfaceStyle = userInterfaceStyle
            mutableTraits.displayScale = 1
        }

        #elseif canImport(AppKit)
        let appearanceName: NSAppearance.Name = switch colorScheme {
        case .light:
            .aqua
        case .dark:
            .darkAqua
        @unknown default:
            .aqua
        }
        appearance = .init(named: appearanceName)
        #endif
    }
}
#endif
