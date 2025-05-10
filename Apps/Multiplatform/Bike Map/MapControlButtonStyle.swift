import SwiftUI

/// A button style that matches the style of the standard `Map` controls.
struct MapControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .labelStyle(.iconOnly)
            .font(.init(default: .body, macOS: .callout))
            .foregroundStyle(default: .tint, macOS: configuration.isPressed ? .primary : .secondary)
            .opacity(.init(default: configuration.isPressed ? 0.2 : 1.0, macOS: 1.0))
            .frame(width: .init(default: 44, macOS: 36), height: .init(default: 44, macOS: 24))
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

extension ButtonStyle where Self == MapControlButtonStyle {
    static var mapControl: MapControlButtonStyle {
        MapControlButtonStyle()
    }
}

#Preview {
    Button("Example", systemImage: "star") {}
        .buttonStyle(.mapControl)
}
