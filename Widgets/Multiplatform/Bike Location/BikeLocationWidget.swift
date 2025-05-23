import AVFoundation
import BikeCore
import Contacts
import MapKit
import SwiftUI
import WidgetKit

/// A widget allowing to preview the location of the bike, similar to the Apple "Find my" widget.
///
/// This widget is available in the following sizes:
/// - System small (iOS and macOS)
/// - System medium (iOS and macOS)
struct BikeLocationWidget: Widget {
    let kind: String = "BikeLocationWidget"

    private let client = Client(AppClient(authenticator: .init(Authenticator(AppAuthenticator()))))

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(client: client)) { entry in
            BikeLocationWidgetSystemView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Bike")
        .description("Check your bike's location and battery level.")
        .supportedFamilies([.systemSmall,
                            .systemMedium])
    }
}

extension BikeLocationWidget {
    struct Entry: TimelineEntry, Sendable {
        let date: Date

        let state: State

        enum State: Sendable {
            case loaded(Content)
            case error(Error)

            struct Content: Sendable {
                let date: Date
                let placemark: CLPlacemark?
                let batteryPercentage: Double
                let mapSnapshot: MapSnapshot

                struct MapSnapshot: Sendable {
                    let lightImage: OSImage
                    let darkImage: OSImage
                    let bikeMarkerPosition: CGPoint
                }
            }
        }
    }
}

extension BikeLocationWidget {
    struct Provider: TimelineProvider {
        let client: Client

        func placeholder(in context: Context) -> Entry {
            .init(date: .now, state: .loaded(.placeholder))
        }

        func getSnapshot(in context: Context, completion: @escaping @Sendable (Entry) -> Void) {
            let configuration = Configuration(context: context)

            Task {
                let entry = await getEntry(for: configuration)
                completion(entry)
            }
        }

        func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> Void) {
            let configuration = Configuration(context: context)

            Task {
                let entry = await getEntry(for: configuration)

                let timeInterval: Double = switch entry.state {
                case .loaded:
                    15 * 60
                case .error:
                    5 * 60
                }

                completion(.init(entries: [entry], policy: .after(.now.addingTimeInterval(timeInterval))))
            }
        }

        private func getEntry(for configuration: Configuration) async -> Entry {
            let state: Entry.State

            do {
                let bike = try await getBike()

                let coordinates = CLLocationCoordinate2D(latitude: bike.lastLocation.lat,
                                                         longitude: bike.lastLocation.lon)

                let mapSnapshot = try await generateMapSnapshot(for: coordinates, configuration: configuration)
                let placemark = try await getPlacemark(for: coordinates)

                state = .loaded(.init(date: bike.lastLocation.date,
                                      placemark: placemark,
                                      batteryPercentage: Double(bike.batteryPercentage) / 100.0,
                                      mapSnapshot: mapSnapshot))

            } catch {
                state = .error(error)
            }

            return Entry(date: .now, state: state)
        }

        enum Error: Swift.Error {
            case missingBike
        }

        private func getBike() async throws -> Bike {
            guard let bike = try await client.getBikes().first else {
                throw Error.missingBike
            }

            return bike
        }

        /// Generate a map snapshot that is used as background in the widget, in light and dark mode.
        private func generateMapSnapshot(for coordinates: CLLocationCoordinate2D,
                                         configuration: Configuration) async throws -> Entry.State.Content.MapSnapshot {
            print("Generating snapshot")

            // We rely on empiric values to closely match the Apple "Find my" widget.
            let delta: CLLocationDegrees
            let mapRectOffset: Double

            switch configuration.family {
            case .systemSmall:
                delta = 0.004
                mapRectOffset = 0.2
            case .systemMedium:
                delta = 0.008
                mapRectOffset = 0.3
            default:
                // Other family are not supported.
                delta = 0
                mapRectOffset = 0
            }

            let options = MKMapSnapshotter.Options()

            // The snapshot will occupy the entire widget.
            options.size = configuration.displaySize

            // Setup the snapshotter `region` and `size`, centering on the coordinates. The snapshotter updates the
            // value in the `mapRect` property to match the corresponding area as closely as possible.
            options.region = .init(center: coordinates, span: .init(latitudeDelta: delta, longitudeDelta: delta))
            let approximateMapRect = options.mapRect

            // Compute a `mapRect` that exactly matches the aspect ratio of the desired image size.
            let exactMapRect = MKMakeMapRect(aspectRatio: configuration.displaySize, insideRect: approximateMapRect)

            // The bike is offset from the center. Offset the `exactMapRect` by the desired proportion.
            options.mapRect = exactMapRect.offsetBy(dx: -mapRectOffset * exactMapRect.width, dy: 0)

            // Generate the map snapshot for light mode.
            options.configure(for: .light)
            let lightSnapshotter = MKMapSnapshotter(options: options)
            let lightSnapshot = try await lightSnapshotter.start()

            // Generate the map snapshot for dark mode.
            options.configure(for: .dark)
            let darkSnapshotter = MKMapSnapshotter(options: options)
            let darkSnapshot = try await darkSnapshotter.start()

            print("Success generating snapshot")

            // Save the point corresponding to the initial coordinates, to properly position the bike marker over the
            // snapshot.
            let bikeMarkerPosition = lightSnapshot.point(for: coordinates)

            return .init(lightImage: lightSnapshot.image,
                         darkImage: darkSnapshot.image,
                         bikeMarkerPosition: bikeMarkerPosition)
        }

        /// Get a `CLPlacemark` for the given `CLLocationCoordinate2D`, so we can display human readable location.
        private func getPlacemark(for coordinates: CLLocationCoordinate2D) async throws -> CLPlacemark? {
            print("Getting placemark")

            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let placemark = try await geocoder.reverseGeocodeLocation(location).first

            print("Success getting placemark")

            return placemark
        }
    }

    /// Wrapper around relevant `TimelineProviderContext` values, as `TimelineProviderContext` itself is not `Sendable`.
    private struct Configuration {
        let family: WidgetFamily
        let displaySize: CGSize

        init(context: TimelineProviderContext) {
            family = context.family
            displaySize = context.displaySize
        }
    }
}

private extension BikeLocationWidget.Entry.State.Content {
    static let placeholder = Self(date: .now,
                                  placemark: .placeholder,
                                  batteryPercentage: 0,
                                  mapSnapshot: .init(lightImage: OSImage(),
                                                     darkImage: OSImage(),
                                                     bikeMarkerPosition: .zero))
}

private extension CLPlacemark {
    static let placeholder = CLPlacemark(location: .init(), name: "1 rue de la Paix", postalAddress: nil)
}

#Preview("System Small", as: .systemSmall) {
    BikeLocationWidget()
} timeline: {
    BikeLocationWidget.Entry(date: .now, state: .loaded(.preview(for: .systemSmall)))
}

#Preview("System Medium", as: .systemMedium) {
    BikeLocationWidget()
} timeline: {
    BikeLocationWidget.Entry(date: .now, state: .loaded(.preview(for: .systemMedium)))
}

/// `MKMapRect` equivalent of `AVMakeRect(aspectRatio:insideRect:)`.
private func MKMakeMapRect(aspectRatio: CGSize, insideRect boundingRect: MKMapRect) -> MKMapRect {
    let cgRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: .init(x: boundingRect.origin.x,
                                                                        y: boundingRect.origin.y,
                                                                        width: boundingRect.width,
                                                                        height: boundingRect.height))

    return MKMapRect(x: cgRect.origin.x, y: cgRect.origin.y, width: cgRect.size.width, height: cgRect.size.height)
}

#if canImport(AppKit)
extension NSImage: @unchecked @retroactive Sendable {}
#endif
