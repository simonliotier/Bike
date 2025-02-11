import SwiftUI

/// Allow smooth animation of `safeAreaPadding` in a `Map`.
///
/// See https://iosdev.space/@alpennec/112336401327256887
struct AnimatableSafeAreaPadding: ViewModifier, @preconcurrency Animatable {
    var padding: Double

    var animatableData: Double {
        get { padding }
        set { padding = newValue }
    }

    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.bottom, padding)
    }
}
