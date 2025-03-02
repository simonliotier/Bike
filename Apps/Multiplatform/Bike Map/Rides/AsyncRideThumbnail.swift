import Bike
import SwiftUI

/// A view that asynchronously loads and displays a thumbnail of a ride.
struct AsyncRideThumbnail: View {
    let ride: Ride

    @State private var thumbnail: RideThumbnail?

    @Environment(Client.self) private var client

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.quinary)
                .overlay {
                    if let thumbnail {
                        Image(osImage: thumbnail.image(for: colorScheme))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    }
                }
        }
        .clipped()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard let thumbnail = try? await generateThumbnail() else {
                return
            }

            withAnimation {
                self.thumbnail = thumbnail
            }
        }
    }

    private func generateThumbnail() async throws -> RideThumbnail {
        return try await RideThumbnailGenerator(client: client).rideThumbnail(for: ride)
    }
}

#Preview {
    AsyncRideThumbnail(ride: .previewAfternoon)
        .frame(width: 100, height: 100)
        .environment(PreviewClient())
        .environment(Client.preview)
}
