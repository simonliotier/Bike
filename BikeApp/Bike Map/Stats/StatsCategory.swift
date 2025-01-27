import Bike
import Foundation
import SwiftUI

enum StatsCategory: CaseIterable, Identifiable {
    case distance
    case averageSpeed
    case topSpeed
    case co2
    case calories

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .distance:
            "Distance"
        case .averageSpeed:
            "Average Speed"
        case .topSpeed:
            "Top Speed"
        case .co2:
            "CO₂ saved"
        case .calories:
            "Calories"
        }
    }

    var aggregationMethod: AggregationMethod {
        switch self {
        case .distance,
             .co2,
             .calories:
            return .sum
        case .averageSpeed:
            return .average
        case .topSpeed:
            return .max
        }
    }

    enum AggregationMethod {
        case sum
        case average
        case max
    }

    var tint: Color {
        switch self {
        case .distance:
            .blue
        case .averageSpeed:
            .green
        case .topSpeed:
            .orange
        case .co2:
            .cyan
        case .calories:
            .red
        }
    }
}
