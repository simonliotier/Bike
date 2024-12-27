import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit)
    import AppKit
#endif

extension Color {
    /// Convenience initializer to create dynamic color on all platforms.
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
            self.init(light: UIColor(light), dark: UIColor(dark))
        #else
            self.init(light: NSColor(light), dark: NSColor(dark))
        #endif
    }

    #if canImport(UIKit)
        init(light: UIColor, dark: UIColor) {
            #if os(watchOS)
                // watchOS does not support light mode / dark mode. Per Apple HIG, prefer dark-style interfaces.
                self.init(uiColor: dark)
            #else
                self.init(uiColor: UIColor(dynamicProvider: { traits in
                    switch traits.userInterfaceStyle {
                    case .light, .unspecified:
                        return light

                    case .dark:
                        return dark

                    @unknown default:
                        assertionFailure("Unknown userInterfaceStyle: \(traits.userInterfaceStyle)")
                        return light
                    }
                }))
            #endif
        }
    #endif

    #if canImport(AppKit)
        init(light: NSColor, dark: NSColor) {
            self.init(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
                switch appearance.name {
                case .aqua,
                     .vibrantLight,
                     .accessibilityHighContrastAqua,
                     .accessibilityHighContrastVibrantLight:
                    return light

                case .darkAqua,
                     .vibrantDark,
                     .accessibilityHighContrastDarkAqua,
                     .accessibilityHighContrastVibrantDark:
                    return dark

                default:
                    assertionFailure("Unknown appearance: \(appearance.name)")
                    return light
                }
            }))
        }
    #endif
}
