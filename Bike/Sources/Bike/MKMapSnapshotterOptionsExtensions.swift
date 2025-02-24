import MapKit
import SwiftUI

#if os(iOS) || os(macOS)
    public extension MKMapSnapshotter.Options {
        /// Convenience method to configure snapshotter options for light/dark mode, on iOS and macOS.
        func configure(for colorScheme: ColorScheme) {
            #if os(iOS)
                let userInterfaceStyle: UIUserInterfaceStyle = switch colorScheme {
                case .light:
                    .light
                case .dark:
                    .dark
                @unknown default:
                    .light
                }
                traitCollection = .init(userInterfaceStyle: userInterfaceStyle)
            #elseif os(macOS)
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
