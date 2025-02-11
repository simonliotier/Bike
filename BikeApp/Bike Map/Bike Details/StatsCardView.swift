import Bike
import Charts
import SwiftUI

/// Card presenting a preview of the week stats.
struct StatsCardView: View {
    let stats: [Stat]

    let today: Date

    init(stats: [Stat], today: Date = .now) {
        self.stats = stats
        self.today = today
    }

    var body: some View {
        CardView {
            Label("Stats", systemImage: "chart.bar.xaxis")
        } content: {
            VStack(alignment: .leading, spacing: 4) {
                header
                chart
            }
        }
    }

    @ViewBuilder private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("This week")
                .font(.caption)
            Text(formattedDistance)
                .font(.title2)
                .fontDesign(.rounded)
                .bold()
                .foregroundStyle(.accent.gradient)
        }
    }

    @ViewBuilder private var chart: some View {
        Chart {
            ForEach(stats, id: \.from) { stat in
                BarMark(
                    x: .value("Date", stat.from, unit: .day),
                    y: .value("Distance", stat.distanceTraveled),
                    width: 6
                )
                .foregroundStyle(.accent.gradient)
                .clipShape(Capsule())
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { xAxisValue in
                AxisTick(stroke: StrokeStyle(lineWidth: 1))
                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    .foregroundStyle(color(for: xAxisValue))
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
            }
        }

        .chartYAxis(.hidden)
        .frame(idealHeight: 80, maxHeight: .infinity)
    }

    private func color(for xAxisValue: AxisValue) -> Color {
        guard let date = xAxisValue.as(Date.self) else {
            return .primary
        }

        // Attenuates color for future days.
        return date <= today ? .primary : .secondary
    }

    private var formattedDistance: String {
        let distance = stats.reduce(0) { $0 + $1.distanceTraveled }

        return Measurement(value: Double(distance), unit: UnitLength.meters)
            .formatted()
    }
}

#Preview {
    StatsCardView(stats: .previewWeek, today: [Stat].previewWeek[2].from)
        .fixedSize(horizontal: false, vertical: true)
        .padding()
}
