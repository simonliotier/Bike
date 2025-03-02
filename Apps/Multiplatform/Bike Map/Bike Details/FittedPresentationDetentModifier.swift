import SwiftUI

/// Set the view detent so that it fits the view content.
struct FittedPresentationDetentModifier: ViewModifier {
    @State private var height = 0.0

    func body(content: Content) -> some View {
        content
            .onHeightChange { height in
                self.height = height
            }
            .presentationDetents([.height(height)])
    }
}

extension View {
    /// Set the view detent so that it fits the view content.
    func fittedPresentationDetent() -> some View {
        modifier(FittedPresentationDetentModifier())
    }
}
