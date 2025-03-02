import Bike
import Foundation
import SwiftUI

extension StatsChart {
    /// Encapsulates the data displayed by a `StatsChart`.
    struct Data {
        let periodType: StatsPeriodType
        let category: StatsCategory
        let points: [Point]

        var aggregatedValue: Double? {
            let values = points.filter { !$0.isEmpty }.map { Double($0.value) }
            guard !values.isEmpty else { return nil }

            return switch category.aggregationMethod {
            case .sum:
                values.reduce(0, +)
            case .average:
                values.reduce(0, +) / Double(values.count)
            case .max:
                values.max() ?? 0
            }
        }

        /// A single point of `StatsChart.Data`.
        struct Point: Identifiable {
            let date: Date
            let value: Int

            var id: Date {
                date
            }

            var isEmpty: Bool {
                value == 0
            }
        }
    }
}

extension StatsChart.Data {
    /// Initialize a `StatsChart.Data` for a given category by extracting the relevant values from the given stats.
    init(stats: [Stat], periodType: StatsPeriodType, category: StatsCategory) {
        let categoryDataData = stats.map { stat in
            Point(date: stat.from, value: stat[keyPath: category.valueKeyPath])
        }

        self = .init(periodType: periodType, category: category, points: categoryDataData)
    }
}

private extension StatsCategory {
    var valueKeyPath: KeyPath<Stat, Int> {
        switch self {
        case .distance:
            \.distanceTraveled
        case .averageSpeed:
            \.avgSpeed
        case .topSpeed:
            \.topSpeed
        case .co2:
            \.c02
        case .calories:
            \.calories
        }
    }
}
