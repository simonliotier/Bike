import Foundation

enum StatsPeriodType: Identifiable, CaseIterable {
    case day
    case week
    case month

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .day:
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        }
    }
}
