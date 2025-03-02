import SwiftUI

/// Adds an action to be performed when the view height change.
struct OnHeightChangeModifier: ViewModifier {
    let action: (Double) -> Void

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Double.self) { proxy in
                proxy.size.height
            } action: { newValue in
                action(newValue)
            }
    }
}

extension View {
    /// Adds an action to be performed when the view height change.
    func onHeightChange(_ action: @MainActor @escaping (Double) -> Void) -> some View {
        modifier(OnHeightChangeModifier(action: action))
    }
}
