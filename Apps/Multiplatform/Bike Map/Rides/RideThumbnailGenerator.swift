import BikeCore
import Foundation
import MapKit
import SwiftUI

/// Generate ride thumbnails in light and dark modes.
///
/// Thumbnails are automatically cached to disk.
actor RideThumbnailGenerator {
    let client: Client

    init(client: Client) {
        self.client = client
    }

    /// Returns a thumbnail for the give ride.
    func rideThumbnail(for ride: Ride) async throws -> RideThumbnail {
        async let lightImage = try image(for: ride, colorScheme: .light)
        async let darkImage = try image(for: ride, colorScheme: .dark)
        return try await .init(lightImage: lightImage, darkImage: darkImage)
    }

    /// Returns a thumbnail image for the given ride and color scheme, either from cache or by generating one.
    private func image(for ride: Ride, colorScheme: ColorScheme) async throws -> OSImage {
        if let cachedImage = loadThumbnailImage(for: ride, colorScheme: colorScheme) {
            return cachedImage
        } else {
            let image = try await generateThumbnailImage(for: ride, colorScheme: colorScheme)
            saveThumbnailImage(image, for: ride, colorScheme: colorScheme)
            return image
        }
    }

    // MARK: - Cache

    /// Load a thumbnail image from the cache, if it exists.
    private func loadThumbnailImage(for ride: Ride, colorScheme: ColorScheme) -> OSImage? {
        guard let fileURL = thumbnailImageFileURL(for: ride, colorScheme: colorScheme),
              let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return OSImage(data: imageData)
    }

    /// Save a thumbnail image to the cache.
    private func saveThumbnailImage(_ image: OSImage, for ride: Ride, colorScheme: ColorScheme) {
        guard let fileURL = thumbnailImageFileURL(for: ride, colorScheme: colorScheme),
              let pngData = image.pngData() else {
            return
        }

        try? pngData.write(to: fileURL)
    }

    /// Return the cache file URL for a thumbnail image for a given ride and color scheme.
    private func thumbnailImageFileURL(for ride: Ride, colorScheme: ColorScheme) -> URL? {
        let colorSchemeName = switch colorScheme {
        case .light:
            "light"
        case .dark:
            "dark"
        @unknown default:
            "light"
        }

        let imageName = "ride-thumbnail-\(ride.id)-\(colorSchemeName)"

        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        return cachesDirectory.appendingPathComponent(imageName)
    }

    // MARK: - Image generation

    /// Generate the image for a given ride and color scheme.
    @MainActor
    private func generateThumbnailImage(for ride: Ride, colorScheme: ColorScheme) async throws -> OSImage {
        let locations = try await client.getLocations(for: ride.bikeId, from: ride.startDate, till: ride.endDate)

        let options = MKMapSnapshotter.Options()

        guard let minLatitude = locations.map(\.lat).min(),
              let maxLatitude = locations.map(\.lat).max(),
              let minLongitude = locations.map(\.lon).min(),
              let maxLongitude = locations.map(\.lon).max() else {
            fatalError()
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: (maxLatitude - minLatitude) * 1.5,
            longitudeDelta: (maxLongitude - minLongitude) * 1.5
        )

        options.region = MKCoordinateRegion(center: center, span: span)
        options.configure(for: colorScheme)

        let snapshotter = MKMapSnapshotter(options: options)
        let snapshot = try await snapshotter.start()

        let points = locations.map { location in
            let point = snapshot.point(for: location.coordinate2D)

            #if os(macOS)
            // On macOS, the points provided by `MKMapSnapshot.point(for:)` are expressed in the macOS coordinate
            // system. The y-coordinates must be flipped to be used in SwiftUI, which relies in the iOS coordinate
            // system.
            let flippedY = snapshot.image.size.height - point.y
            return CGPoint(x: point.x, y: flippedY)
            #else
            return point
            #endif
        }

        let renderer = ImageRenderer(content: RideThumbnailView(snapshotImage: snapshot.image,
                                                                points: points,
                                                                size: options.size))

        guard let image = renderer.osImage else {
            fatalError()
        }

        return image
    }
}

extension MKMapSnapshotter.Snapshot: @unchecked @retroactive Sendable {}
