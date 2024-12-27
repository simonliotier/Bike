import Bike
import SwiftUI

/// A view that asynchronously loads and displays a thumbnail of a ride.
struct AsyncRideThumbnail: View {
    let ride: Ride

    @State private var thumbnail: RideThumbnail?

    @Environment(\.client) private var client
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.quinary)
            if let thumbnail {
                Image(osImage: thumbnail.image(for: colorScheme))
                    .resizable()
            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
        .frame(width: 50, height: 50)
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
        .environment(\.client, PreviewClient())
}
