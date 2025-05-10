import SwiftUI

/// A card container view displayed in the `BikeDetailsView`.
struct CardView<Title: View, Content: View>: View {
    @ViewBuilder var title: Title
    @ViewBuilder var content: Content

    @ScaledMetric private var titleHeight: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                title
                    .font(.subheadline)
                    .bold()
                    .frame(height: titleHeight)
            }

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    CardView {
        Label("Title", systemImage: "star")
    } content: {
        Text("This is the card content.")
    }
}
