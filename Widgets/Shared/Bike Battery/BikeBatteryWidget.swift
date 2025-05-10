import Bike
import SwiftUI
import WidgetKit

/// A widget allowing to preview the battery of the bike, similar to the Apple "Batteries" widget.
///
/// This widget is available in the following sizes:
/// - System small (iOS and macOS)
/// - Accessory circular (iOS and watchOS)
/// - Accessory corner (iOS and watchOS)
/// - Accessory rectangular (iOS and watchOS)
/// - Accessory inline (iOS and watchOS)
///
/// The implementation is shared between the Multiplatform Widget Extension and the Watch Widget Extension. To avoid a
/// an issue with Xcode previews, it is then wrapped in platform specific widgets: ``BikeBatteryWidgetMultiplatform``
/// and ``BikeBatteryWidgetWatch``.
struct BikeBatteryWidget: Widget {
    let kind: String = "BikeBatteryWidget"

    private let client = Client(AppClient(authenticator: .init(Authenticator(AppAuthenticator()))))

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(client: client)) { entry in
            BikeBatteryWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Rectangle().fill(.decathlon.gradient)
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Charge")
        .description("Check your bike's charge level.")
    }
}

extension BikeBatteryWidget {
    struct Entry: TimelineEntry, Sendable {
        let date: Date

        let state: State

        enum State {
            case loaded(Content)
            case error(Error)

            struct Content {
                let name: String
                let batteryPercentage: Double
            }
        }
    }
}

extension BikeBatteryWidget {
    struct Provider: TimelineProvider {
        let client: Client

        func placeholder(in _: Context) -> Entry {
            return .init(date: .now, state: .loaded(.placeholder))
        }

        func getSnapshot(in _: Context, completion: @escaping @Sendable (Entry) -> Void) {
            Task {
                let entry = await getEntry()
                completion(entry)
            }
        }

        func getTimeline(in _: Context, completion: @escaping @Sendable (Timeline<Entry>) -> Void) {
            Task {
                let entry = await getEntry()

                let timeInterval: Double = switch entry.state {
                case .loaded:
                    15 * 60
                case .error:
                    5 * 60
                }

                completion(.init(entries: [entry], policy: .after(.now.addingTimeInterval(timeInterval))))
            }
        }

        private func getEntry() async -> Entry {
            let state: Entry.State

            do {
                guard let bike = try await client.getBikes().first else {
                    throw Error.missingBike
                }

                state = .loaded(.init(name: bike.name, batteryPercentage: Double(bike.batteryPercentage) / 100.0))
            } catch {
                state = .error(error)
            }

            return Entry(date: .now, state: state)
        }

        enum Error: Swift.Error {
            case missingBike
        }
    }
}

private extension BikeBatteryWidget.Entry.State.Content {
    static let placeholder: Self = .init(name: "Elops 920E", batteryPercentage: 1)
}
