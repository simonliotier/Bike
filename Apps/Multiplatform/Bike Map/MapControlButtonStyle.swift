import SwiftUI

/// A button style that matches the style of the standard `Map` controls.
struct MapControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .labelStyle(.iconOnly)
            .font(.init(iOS: .body, macOS: .callout, visionOS: .body))
            .foregroundStyle(iOS: .tint, macOS: configuration.isPressed ? .primary : .secondary, visionOS: .tint)
            .opacity(.init(iOS: configuration.isPressed ? 0.2 : 1.0, macOS: 1.0, visionOS: 1.0))
            .frame(width: .init(iOS: 44, macOS: 36, visionOS: 44), height: .init(iOS: 44, macOS: 24, visionOS: 44))
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
