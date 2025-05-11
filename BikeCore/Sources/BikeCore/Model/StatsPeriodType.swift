import Foundation

public enum StatsPeriodType: Identifiable, CaseIterable {
    case day
    case week
    case month

    public var id: Self {
        self
    }

    public var displayName: String {
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
