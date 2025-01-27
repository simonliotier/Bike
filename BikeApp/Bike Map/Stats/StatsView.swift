import Bike
import SwiftUI

/// Display all the bike stats.
struct StatsView: View {
    let allPeriodStats: AllPeriodsStats

    @State private var periodType: StatsPeriodType = .week

    var body: some View {
        ScrollView {
            Text("Stats")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.largeTitle)
                .bold()

            Text(periodTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .foregroundStyle(.secondary)

            Picker("Period", selection: $periodType) {
                ForEach(StatsPeriodType.allCases) { periodType in
                    Text(periodType.displayName)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            ForEach(StatsCategory.allCases) { category in
                StatsChart(data: .init(stats: allPeriodStats.stats(for: periodType),
                                       periodType: periodType,
                                       category: category))

                if category != StatsCategory.allCases.last {
                    Divider()
                }
            }
        }
        .padding()
    }

    var periodTitle: String {
        switch periodType {
        case .day:
            return "Today"
        case .week:
            return "This week"
        case .month:
            return "This month"
        }
    }

    struct AllPeriodsStats {
        let dayStats: [Stat]
        let weekStats: [Stat]
        let monthStats: [Stat]

        func stats(for periodType: StatsPeriodType) -> [Stat] {
            switch periodType {
            case .day:
                dayStats
            case .week:
                weekStats
            case .month:
                monthStats
            }
        }
    }
}

#Preview {
    StatsView(allPeriodStats: .init(dayStats: .previewDay, weekStats: .previewWeek, monthStats: .previewMonth))
}
