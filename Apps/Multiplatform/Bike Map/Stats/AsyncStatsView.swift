import Bike
import SwiftUI

/// Loads and displays all the bike stats.
struct AsyncStatsView: View {
    let bike: Bike

    @Environment(Client.self) private var client

    var body: some View {
        AsyncContentView(asyncContent: Content(bike: bike, client: client)) { allPeriodStats in
            StatsView(allPeriodStats: allPeriodStats)
        }
        .navigationTitle("Stats")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                DismissButton()
            }
            #endif
        }
    }
}

extension AsyncStatsView {
    @Observable
    class Content: AsyncContent {
        let bike: Bike
        let client: Client
        var state: AsyncContentState<StatsView.AllPeriodsStats> = .loading

        init(bike: Bike, client: Client) {
            self.bike = bike
            self.client = client
        }

        func load() async {
            do {
                async let dayStats = try await getDayStats()
                async let weekStats = try await getWeekStats()
                async let monthStats = try await getMonthStats()

                let allPeriodStats = try await StatsView.AllPeriodsStats(dayStats: dayStats,
                                                                         weekStats: weekStats,
                                                                         monthStats: monthStats)

                state = .loaded(allPeriodStats)
            } catch {
                state = .failed(error)
            }
        }

        private func getDayStats() async throws -> [Stat] {
            let from = Calendar.current.startOfCurrentDay
            let till = Calendar.current.endOfCurrentDay

            return try await client.getStats(for: bike.id, from: from, till: till, granularity: .hourly)
        }

        private func getWeekStats() async throws -> [Stat] {
            let from = Calendar.current.startOfCurrentWeek
            let till = Calendar.current.endOfCurrentWeek

            return try await client.getStats(for: bike.id, from: from, till: till, granularity: .daily)
        }

        private func getMonthStats() async throws -> [Stat] {
            let from = Calendar.current.startOfCurrentMonth
            let till = Calendar.current.endOfCurrentMonth

            return try await client.getStats(for: bike.id, from: from, till: till, granularity: .daily)
        }
    }
}

#Preview {
    NavigationStack {
        AsyncStatsView(bike: .preview)
            .environment(Client.preview)
    }
}

/// A set of convenience properties to retrieve the start and end `Date`s for the current day, week, and month.
///
/// **Note**: When calculating end dates, we subtract one second from the interval's `end` value. This ensures any
/// range-based queries (e.g., daily/weekly/monthly stats) include the entire final calendar unit up to 23:59:59 on the
/// last day, rather than spilling into the next day, week, or month.
extension Calendar {
    var currentDayInterval: DateInterval? {
        dateInterval(of: .day, for: .now)
    }

    var startOfCurrentDay: Date {
        currentDayInterval?.start ?? .now
    }

    var endOfCurrentDay: Date {
        currentDayInterval?.end.addingTimeInterval(-1) ?? .now
    }

    var currentWeekInterval: DateInterval? {
        dateInterval(of: .weekOfYear, for: .now)
    }

    var startOfCurrentWeek: Date {
        currentWeekInterval?.start ?? Date()
    }

    var endOfCurrentWeek: Date {
        currentWeekInterval?.end.addingTimeInterval(-1) ?? Date()
    }

    var currentMonthInterval: DateInterval? {
        dateInterval(of: .month, for: .now)
    }

    var startOfCurrentMonth: Date {
        currentMonthInterval?.start ?? .now
    }

    var endOfCurrentMonth: Date {
        currentMonthInterval?.end.addingTimeInterval(-1) ?? .now
    }
}
