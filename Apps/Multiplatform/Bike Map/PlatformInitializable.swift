import SwiftUI

/// Types implementing this protocol can be initialized with a different value, depending on the platform.
protocol PlatformInitializable {
    init(default: Self, iOS: Self?, macOS: Self?, visionOS: Self?, tvOS: Self?)
}

extension PlatformInitializable {
    /// Initialize the type with the given iOS or macOS value, depending on the current platform.
    init(default: Self, iOS: Self? = nil, macOS: Self? = nil, visionOS: Self? = nil, tvOS: Self? = nil) {
        #if os(iOS)
        self = iOS ?? `default`
        #elseif os(macOS)
        self = macOS ?? `default`
        #elseif os(visionOS)
        self = visionOS ?? `default`
        #elseif os(tvOS)
        self = tvOS ?? `default`
        #else
        self = `default`
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
    /// Sets a view’s foreground style to either:
    ///   - A platform-specific `ShapeStyle`, if provided
    ///   - Or else a required fallback `defaultStyle`.
    @ViewBuilder
    func foregroundStyle(
        default: any ShapeStyle,
        iOS: (any ShapeStyle)? = nil,
        macOS: (any ShapeStyle)? = nil,
        visionOS: (any ShapeStyle)? = nil,
        tvOS: (any ShapeStyle)? = nil
    ) -> some View {
        #if os(iOS)
        if let iOS {
            foregroundStyle(AnyShapeStyle(iOS))
        } else {
            foregroundStyle(AnyShapeStyle(`default`))
        }
        #elseif os(macOS)
        if let macOS {
            foregroundStyle(AnyShapeStyle(macOS))
        } else {
            foregroundStyle(AnyShapeStyle(`default`))
        }
        #elseif os(visionOS)
        if let visionOS {
            foregroundStyle(AnyShapeStyle(visionOS))
        } else {
            foregroundStyle(AnyShapeStyle(`default`))
        }
        #elseif os(tvOS)
        if let tvOS {
            foregroundStyle(AnyShapeStyle(tvOS))
        } else {
            foregroundStyle(AnyShapeStyle(`default`))
        }
        #else
        foregroundStyle(AnyShapeStyle(`default`))
        #endif
    }
}
