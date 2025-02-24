import Bike
import SwiftUI
import WidgetKit

/// A widget allowing to preview the battery of the bike, similar to the Apple "Batteries" widget.
///
/// This widget is available in the following sizes:
/// - System small (iOS and macOS)
/// - Accessory circular (iOS)
/// - Accessory rectangular (iOS)
/// - Accessory inline (iOS)
struct BikeBatteryWidget: Widget {
    let kind: String = "BikeBatteryWidget"

    private let client = Client(client: APIClient(authenticationController: .init()))

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(client: client)) { entry in
            BikeBatteryWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Rectangle().fill(.decathlon.gradient)
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Charge")
        .description("Consultez le niveau de charge de votre vélo.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
            return [.systemSmall,
                    .accessoryCircular,
                    .accessoryRectangular,
                    .accessoryInline]
        #endif

        #if os(macOS)
            return [.systemSmall]
        #endif
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

        func placeholder(in context: Context) -> Entry {
            return .init(date: .now, state: .loaded(.placeholder))
        }

        func getSnapshot(in context: Context, completion: @escaping @Sendable (Entry) -> Void) {
            Task {
                let entry = await getEntry()
                completion(entry)
            }
        }

        func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> Void) {
            Task {
                let entry = await getEntry()

                let timeInterval: Double = switch entry.state {
                case .loaded(let content):
                    15 * 60
                case .error(let error):
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

#Preview("System Small", as: .systemSmall) {
    BikeBatteryWidget()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#if os(iOS)
    #Preview("Accessory Circular", as: .accessoryCircular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }

    #Preview("Accessory Rectangular", as: .accessoryRectangular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }

    #Preview("Accessory Inline", as: .accessoryInline) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }
#endif
