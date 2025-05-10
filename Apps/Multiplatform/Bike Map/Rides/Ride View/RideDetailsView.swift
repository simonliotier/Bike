import Bike
import SwiftUI

/// Displays the ride details (duration, speed...) in a grid.
struct RideDetailsView: View {
    let ride: Ride

    var body: some View {
        rideDetailPairView((RideDetail(type: .duration, formattedValue: ride.formattedDuration),
                            RideDetail(type: .speed, formattedValue: ride.formattedSpeed)))

        rideDetailPairView((RideDetail(type: .distance, formattedValue: ride.formattedDistance),
                            RideDetail(type: .elevation, formattedValue: ride.formattedElevation)))

        rideDetailPairView((RideDetail(type: .calories, formattedValue: ride.formattedCalories),
                            RideDetail(type: .weather, formattedValue: ride.formattedWeather)))
    }

    private func rideDetailView(for rideDetail: RideDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(rideDetail.type.localizedName, systemImage: rideDetail.type.systemImage)
                .foregroundStyle(.primary)
                .font(.body)
                .bold()
                .labelStyle(.titleAndIcon)

            Text(rideDetail.formattedValue)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func rideDetailPairView(_ pair: (RideDetail, RideDetail)) -> some View {
        LazyVGrid(columns: [.init(), .init()], alignment: .leading) {
            rideDetailView(for: pair.0)
            rideDetailView(for: pair.1)
        }
        #if !os(tvOS)
        // Make the separator trailing inset match the separator leading inset.
        .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
            viewDimensions[.listRowSeparatorTrailing] - viewDimensions[.listRowSeparatorLeading]
        }
        #endif
    }

    private struct RideDetail {
        let type: RideDetailType
        let formattedValue: String

        enum RideDetailType {
            case duration
            case speed
            case distance
            case elevation
            case calories
            case weather

            var localizedName: LocalizedStringKey {
                switch self {
                case .duration:
                    "Duration"
                case .speed:
                    "Speed"
                case .distance:
                    "Distance"
                case .elevation:
                    "Elevation"
                case .calories:
                    "Calories"
                case .weather:
                    "Weather"
                }
            }

            var systemImage: String {
                switch self {
                case .duration:
                    "timer"
                case .speed:
                    "gauge.with.needle"
                case .distance:
                    "arrow.trianglehead.turn.up.right.diamond"
                case .elevation:
                    "mountain.2"
                case .calories:
                    "flame"
                case .weather:
                    "cloud"
                }
            }
        }
    }
}

private extension Ride {
    var formattedDuration: String {
        Duration.seconds(activeTime).formatted(.units())
    }

    var formattedSpeed: String {
        Measurement(value: Double(avgSpeed), unit: UnitSpeed.kilometersPerHour)
            .formatted()
    }

    var formattedDistance: String {
        Measurement(value: Double(distanceTraveled), unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }

    var formattedElevation: String {
        let formattedElevationUp = Measurement(value: Double(elevationUp), unit: UnitLength.meters)
            .formatted()

        let formattedElevationDown = Measurement(value: Double(elevationDown), unit: UnitLength.meters)
            .formatted()

        return ["↑", formattedElevationUp, "↓", formattedElevationDown].joined(separator: " ")
    }

    var formattedCalories: String {
        Measurement(value: Double(calories), unit: UnitEnergy.kilocalories)
            .formatted(.measurement(width: .wide, usage: .food))
    }

    var formattedWeather: String {
        guard let weatherType = weatherInfo.weatherType else {
            return "–"
        }
        return String(localized: weatherType.localizedName)
    }
}

extension WeatherInfo.WeatherType {
    var localizedName: LocalizedStringResource {
        switch self {
        case .cloudy:
            "Cloudy"
        case .rain:
            "Rainy"
        case .wind:
            "Wind"
        case .fog:
            "Fog"
        case .hail:
            "Hail"
        }
    }
}

#Preview {
    List {
        RideDetailsView(ride: .previewMorning)
    }
}
