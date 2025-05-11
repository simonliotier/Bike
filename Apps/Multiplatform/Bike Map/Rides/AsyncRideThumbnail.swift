import BikeCore
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
            do {
                let thumbnail = try await generateThumbnail()
                withAnimation {
                    self.thumbnail = thumbnail
                }
            } catch {
                print("Error generating thumbnail: \(error)")
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
        .environment(Client.preview)
}
