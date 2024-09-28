import SwiftUI

/// A button that sets the framing of the associated map to the bike location.
struct MapBikeLocationButton: View {
    let action: @MainActor () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "bicycle")
                .frame(width: 44, height: 44)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

#Preview {
    MapBikeLocationButton {
        print("Button tapped")
    }
}
