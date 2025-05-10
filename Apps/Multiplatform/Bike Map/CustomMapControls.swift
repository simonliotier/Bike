import MapKit
import SwiftUI

extension View {
    /// Add custom map controls.
    ///
    /// The custom map controls are displayed in a specific corner of the map depending on the platform, so they do not
    /// overlap the standard map controls:
    /// - On macOS, they are displayed horizontally in the bottom trailing corner.
    /// - On other platforms, they are displayed vertically in the top trailing corner.
    func customMapControls(@ViewBuilder _ content: () -> some View) -> some View {
        overlay(alignment: .init(default: .topTrailing, macOS: .bottomTrailing)) {
            Group {
                #if os(iOS) || os(visionOS) || os(tvOS)
                VStack(spacing: 8, content: content)
                #elseif os(macOS)
                HStack(spacing: 4, content: content)
                #endif
            }
            .padding()
        }
    }
}

#Preview {
    Map()
        .customMapControls {
            Button("Example 1", systemImage: "star") {}
                .buttonStyle(.mapControl)
            Button("Example 2", systemImage: "car") {}
                .buttonStyle(.mapControl)
        }
}
