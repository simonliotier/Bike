import Bike
import Charts
import SwiftUI

/// Display the bike stats for a given category and period.
struct StatsChart: View {
    let data: Data

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            chart
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
    }

    @ViewBuilder private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(data.category.displayName)
                .textCase(.uppercase)
                .font(.footnote)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
            Text(formattedAggregatedValue)
                .font(.title2)
                .fontDesign(.rounded)
                .bold()
                .foregroundStyle(data.category.tint)
        }
    }

    private var formattedAggregatedValue: String {
        if let aggregatedValue = data.aggregatedValue {
            formattedValue(for: data.category, value: aggregatedValue)
        } else {
            "--"
        }
    }

    @ViewBuilder private var chart: some View {
        Chart {
            ForEach(data.points) { point in
                BarMark(
                    x: .value("Date", point.date, unit: xDataUnit),
                    y: .value("Distance", point.value)
                )
                .foregroundStyle(data.category.tint.gradient)
                .clipShape(.rect(
                    topLeadingRadius: 2,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 2
                ))
            }
        }
        .chartXAxis {
            AxisMarks(values: xAxisMarkValues) { _ in
                AxisTick()
                AxisValueLabel(format: xAxisValueLabelFormat)
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisTick()

                if let doubleValue = value.as(Double.self) {
                    let formattedValue = formattedValue(for: data.category, value: doubleValue)

                    AxisValueLabel {
                        Text(formattedValue)
                    }
                }
                AxisGridLine()
            }
        }
    }

    private var xDataUnit: Calendar.Component {
        switch data.periodType {
        case .day:
            .hour
        case .week:
            .day
        case .month:
            .day
        }
    }

    private var xAxisValueLabelFormat: Date.FormatStyle {
        switch data.periodType {
        case .day:
            .dateTime.hour()
        case .week:
            .dateTime.weekday(.abbreviated)
        case .month:
            .dateTime.day()
        }
    }

    private var xAxisMarkValues: AxisMarkValues {
        switch data.periodType {
        case .day:
            .stride(by: .hour, count: 6)
        case .week:
            .stride(by: .day)
        case .month:
            .stride(by: .day, count: 7)
        }
    }

    private func formattedValue(for category: StatsCategory, value: Double) -> String {
        return switch category {
        case .distance:
            Measurement(value: Double(value), unit: UnitLength.meters)
                .formatted(.measurement(width: .narrow, usage: .road))
        case .averageSpeed:
            Measurement(value: Double(value), unit: UnitSpeed.kilometersPerHour)
                .formatted(.measurement(width: .narrow, usage: .general))
        case .topSpeed:
            Measurement(value: Double(value), unit: UnitSpeed.kilometersPerHour)
                .formatted(.measurement(width: .narrow, usage: .general))
        case .co2:
            Measurement(value: Double(value), unit: UnitMass.grams)
                .formatted(.measurement(width: .narrow, usage: .general))
        case .calories:
            Measurement(value: Double(value), unit: UnitEnergy.kilocalories)
                .formatted(.measurement(width: .narrow, usage: .food))
        }
    }
}

#Preview {
    @Previewable @State var category: StatsCategory = .distance
    @Previewable @State var periodType: StatsPeriodType = .day

    StatsChart(data: .init(stats: .preview(for: periodType), periodType: periodType, category: category))
        .frame(height: 200)
        .padding()

    HStack {
        Picker("Category", selection: $category) {
            ForEach(StatsCategory.allCases) { category in
                Text(category.displayName)
            }
        }

        Picker("Period", selection: $periodType) {
            ForEach(StatsPeriodType.allCases) { periodType in
                Text(periodType.displayName)
            }
        }
    }
}
