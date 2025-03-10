import SwiftUI
#if os(iOS)
import VariableBlur
#endif

extension View {
    /// On iOS, add a subtle progressive blur behind the status bar to increase its readability over the map, as in the
    /// Map app.
    @ViewBuilder
    func blurredStatusBarBackground() -> some View {
        #if os(iOS)
        overlay {
            GeometryReader { proxy in
                // To create a real progressive blur, we rely on `VariableBlurView` which uses private APIs. It is also
                // possible to apply progressive blur on SwiftUI views using shaders, but this does not work on `Map`.
                VariableBlurView(maxBlurRadius: 4, direction: .blurredTopClearBottom)
                    .frame(height: proxy.safeAreaInsets.top)
                    .ignoresSafeArea()
            }
        }
        #else
        self
        #endif
    }
}
