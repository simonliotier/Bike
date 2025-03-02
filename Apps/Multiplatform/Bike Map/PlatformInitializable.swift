import SwiftUI

/// Types implementing this protocol can be initialized with a different value, depending on the platform.
protocol PlatformInitializable {
    init(iOS: Self, macOS: Self)
}

extension PlatformInitializable {
    /// Initialize the type with the given iOS or macOS value, depending on the current platform.
    init(iOS: Self, macOS: Self) {
        #if os(iOS)
        self = iOS
        #elseif os(macOS)
        self = macOS
        #endif
    }
}

extension CGFloat: PlatformInitializable {}
extension Double: PlatformInitializable {}
extension Font: PlatformInitializable {}
extension EdgeInsets: PlatformInitializable {}
extension Alignment: PlatformInitializable {}

/// For modifiers that take a protocol as parameter, we cannot use the `PlatformInitializable` protocol. We must define
/// a custom modifier.
extension View {
    /// Sets a view’s foreground elements to use a given style, depending on the platform.
    @ViewBuilder
    func foregroundStyle<IOSShapeStyle: ShapeStyle, MacOSShapeStyle: ShapeStyle>(iOS: IOSShapeStyle,
                                                                                 macOS: MacOSShapeStyle) -> some View {
        #if os(iOS)
        foregroundStyle(iOS)
        #elseif os(macOS)
        foregroundStyle(macOS)
        #endif
    }
}
