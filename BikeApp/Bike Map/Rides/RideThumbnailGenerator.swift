import Bike
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
    private func image(for ride: Ride, colorScheme: ColorScheme) async throws -> UIImage {
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
    private func loadThumbnailImage(for ride: Ride, colorScheme: ColorScheme) -> UIImage? {
        guard let fileURL = thumbnailImageFileURL(for: ride, colorScheme: colorScheme),
              let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: imageData)
    }

    /// Save a thumbnail image to the cache.
    private func saveThumbnailImage(_ image: UIImage, for ride: Ride, colorScheme: ColorScheme) {
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
    private func generateThumbnailImage(for ride: Ride, colorScheme: ColorScheme) async throws -> UIImage {
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

        options.traitCollection = .init(userInterfaceStyle: .init(colorScheme))

        let snapshotter = MKMapSnapshotter(options: options)
        let snapshot = try await snapshotter.start()

        let renderer = UIGraphicsImageRenderer(size: options.size)

        return renderer.image { context in
            snapshot.image.draw(at: .zero)

            context.cgContext.setStrokeColor(UIColor(Color.accent.color(for: colorScheme)).cgColor)
            context.cgContext.setLineWidth(10)

            for (index, location) in locations.enumerated() {
                let point = snapshot.point(for: location.coordinate2D)

                if index == 0 {
                    context.cgContext.move(to: point)
                } else {
                    context.cgContext.addLine(to: point)
                }
            }

            context.cgContext.strokePath()
        }
    }
}

extension Color {
    func color(for colorScheme: ColorScheme) -> Color {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        return Color(resolve(in: environment))
    }
}

extension MKMapSnapshotter.Snapshot: @unchecked @retroactive Sendable {}
