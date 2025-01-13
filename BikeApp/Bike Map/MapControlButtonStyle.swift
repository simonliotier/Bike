import SwiftUI

/// A button style that matches the style of the standard `Map` controls.
struct MapControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .labelStyle(.iconOnly)
            .font(.init(iOS: .body, macOS: .callout))
            .foregroundStyle(iOS: .tint, macOS: configuration.isPressed ? .primary : .secondary)
            .opacity(.init(iOS: configuration.isPressed ? 0.2 : 1.0, macOS: 1.0))
            .frame(width: .init(iOS: 44, macOS: 36), height: .init(iOS: 44, macOS: 24))
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
