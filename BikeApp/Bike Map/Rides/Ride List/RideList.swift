import Bike
import SwiftUI

/// Displays the full list of rides.
struct RideList: View {
    let bike: Bike
    let rides: [Ride]

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.localizedName) {
                    ForEach(section.rides) { ride in
                        NavigationLink(value: ride) {
                            RideRow(ride: ride)
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationDestination(for: Ride.self) { ride in
            AsyncRideView(bike: bike, ride: ride)
        }
    }

    fileprivate struct MonthSection: Identifiable {
        let yearMonth: YearMonth
        let rides: [Ride]

        var id: String {
            yearMonth.id
        }

        var localizedName: String {
            let rideCount = String(localized: "\(rides.count) rides")

            let formattedDistance: String = {
                let distance = rides.map(\.distanceTraveled).reduce(0, +)

                return Measurement(value: Double(distance), unit: UnitLength.meters)
                    .formatted(.measurement(width: .abbreviated, usage: .road))

            }()

            return [yearMonth.localizedName, rideCount, formattedDistance].joined(separator: " • ")
                .capitalizedSentence
        }

        struct YearMonth: Hashable, Comparable, Identifiable {
            let month: Int
            let year: Int

            var id: String {
                "\(year)-\(month)"
            }

            var localizedName: String {
                guard let date = Calendar.current.date(from: DateComponents(year: year, month: month)) else {
                    return ""
                }

                return date.formatted(Date.FormatStyle().year().month(.wide))
            }

            static func < (lhs: YearMonth, rhs: YearMonth) -> Bool {
                if lhs.year == rhs.year {
                    return lhs.month < rhs.month
                }

                return lhs.year < rhs.year
            }
        }
    }

    private var sections: [MonthSection] {
        Dictionary(grouping: rides) { ride in
            ride.yearMonth
        }
        .map { yearMonth, rides in
            MonthSection(yearMonth: yearMonth, rides: rides)
        }
        .sorted(using: KeyPathComparator(\.yearMonth, order: .reverse))
    }
}

private extension Ride {
    var yearMonth: RideList.MonthSection.YearMonth {
        let components = Calendar.current.dateComponents([.year, .month], from: startDate)
        return .init(month: components.month ?? 0, year: components.year ?? 0)
    }
}

#Preview {
    NavigationStack {
        RideList(bike: .preview, rides: .preview)
    }
}
