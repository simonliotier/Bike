import SwiftUI

/// A card container view displayed in the `BikeDetailsView`.
struct CardView<Title: View, Content: View>: View {
    @ViewBuilder var title: Title
    @ViewBuilder var content: Content

    @ScaledMetric private var titleHeight: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                title
                    .font(.subheadline)
                    .bold()
                    .frame(height: titleHeight)

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }
            .padding(.init(top: 16, leading: 16, bottom: 8, trailing: 16))
            Divider()
            content
                .padding(.init(top: 8, leading: 16, bottom: 16, trailing: 16))
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .modifier(CardBackgroundModifier())
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
        CardView {
            Label("Title", systemImage: "star")
        } content: {
            Text("This is the card content.")
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}
