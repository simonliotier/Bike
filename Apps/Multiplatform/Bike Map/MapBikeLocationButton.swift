import SwiftUI

/// A button that sets the framing of the associated map to the bike location.
struct MapBikeLocationButton: View {
    let action: () -> Void

    var body: some View {
        Button("Show bike location", systemImage: "bicycle", action: action)
            .buttonStyle(.mapControl)
    }
}

#Preview {
    MapBikeLocationButton {
        print("Button tapped")
    }
}
