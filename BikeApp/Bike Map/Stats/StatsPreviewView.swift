import Bike
import Charts
import SwiftUI

/// WIP.
struct StatsPreviewView: View {
    let stats: [Stat]

    private var formattedDistance: String {
        let distance = stats.reduce(0) { $0 + $1.distanceTraveled }

        return Measurement(value: Double(distance), unit: UnitLength.meters)
            .formatted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Stats", systemImage: "chart.bar.xaxis")
                    .font(.subheadline)
                    .bold()
                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
            }

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                Text("Last 7 days")
                    .font(.caption)
                Text(formattedDistance)
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()
                    .foregroundStyle(.accent.gradient)
            }
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
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisTick(stroke: StrokeStyle(lineWidth: 1))

                    if let date = value.as(Date.self) {
                        AxisValueLabel(centered: true) {
                            Text(date, format: .dateTime.weekday(.narrow))
                        }
                    }

                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                }
            }

            .chartYAxis(.hidden)

            Text("Today: 7,2 km")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
                .bold()
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
        .frame(width: 180, height: 180)
    }
}

#Preview {
    HStack {
        StatsPreviewView(stats: .previewWeek)
    }
}
