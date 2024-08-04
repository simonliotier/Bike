import Foundation
import SwiftUI
import WidgetKit

/// View used for the `systemSmall` and `systemMedium` `BikeLocationWidget`.
struct BikeLocationWidgetSystemView: View {
    var entry: BikeLocationWidget.Entry

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            ZStack {
                Image(osImage: content.mapSnapshot.image(for: colorScheme))
                    .resizable()

                if content.mapSnapshot.bikeMarkerPosition != .zero {
                    BikeMarker()
                        .position(content.mapSnapshot.bikeMarkerPosition)
                }

                VStack {
                    Color.clear

                    EllipticalGradient(colors: [Color(osColor: .mapBackground), .clear],
                                       center: .bottomLeading,
                                       startRadiusFraction: 0.2,
                                       endRadiusFraction: 1)
                }
            }
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 2, content: {
                        Image(batteryPercentage: content.batteryPercentage)
                        Text(content.batteryPercentage.formatted(.percent))
                    })
                    .font(.caption)
                    .bold()
                    .shadow(color: .systemBackground, radius: 2)

                    Spacer()

                    Text(content.dateString)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let name = content.placemark?.name {
                        Text(name)
                            .font(.caption)
                            .bold()
                    }

                    if let locality = content.placemark?.locality {
                        Text(locality)
                            .font(.caption2)
                    }
                }
                .lineLimit(1)
                .padding()
            }
        case .error(let error):
            Text(error.localizedDescription)
                .font(.caption2)
                .padding()
        }
    }
}

private extension Image {
    // Create an image using the battery system image that most closely matches the battery percentage.
    init(batteryPercentage: Double) {
        let images = [
            0.00: "battery.0percent",
            0.25: "battery.25percent",
            0.50: "battery.50percent",
            0.75: "battery.75percent",
            1.00: "battery.100percent"
        ]

        guard let closest = images.keys.min(by: { abs($0 - batteryPercentage) < abs($1 - batteryPercentage) }),
              let systemName = images[closest] else {
            self.init("")
            return
        }

        self.init(systemName: systemName)
    }
}

private extension BikeLocationWidget.Entry.State.Content {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date).capitalizedSentence
    }
}

private extension BikeLocationWidget.Entry.State.Content.MapSnapshot {
    func image(for colorScheme: ColorScheme) -> OSImage {
        colorScheme == .light ? lightImage : darkImage
    }
}

private extension String {
    var capitalizedSentence: String {
        let firstLetter = prefix(1).capitalized
        let remainingLetters = dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
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

extension Image {
    init(osImage: OSImage) {
        #if os(iOS)
            self.init(uiImage: osImage)
        #endif
        #if os(macOS)
            self.init(nsImage: osImage)
        #endif
    }
}

#if os(iOS)
    typealias OSColor = UIColor
#endif

#if os(macOS)
    typealias OSColor = NSColor
#endif

extension Color {
    init(osColor: OSColor) {
        #if os(iOS)
            self.init(osColor)
        #endif
        #if os(macOS)
            self.init(nsColor: osColor)
        #endif
    }

    static var systemBackground: Color {
        #if os(iOS)
            return Color(osColor: .systemBackground)
        #endif
        #if os(macOS)
            return Color(osColor: .textBackgroundColor)
        #endif
    }
}
