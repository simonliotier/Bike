import SwiftUI

struct MaterialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .modifier(CardBackgroundModifier())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct CardBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(content: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .opacity(colorScheme == .dark ? 0.1 : 0.9)

            })
            .shadow(color: .black.opacity(0.1), radius: 20)
    }
}

extension ButtonStyle where Self == MaterialButtonStyle {
    static var material: MaterialButtonStyle {
        MaterialButtonStyle()
    }
}

#Preview {
    ZStack {
        Color.teal
        Rectangle()
            .foregroundStyle(.regularMaterial)
    }
    .ignoresSafeArea()
    .overlay {
        Button("Example", systemImage: "star") {}
            .buttonStyle(.material)
    }
}
