import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetRectangularView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            VStack(alignment: .leading) {
                Label(content.batteryPercentage.formatted(.percent), systemImage: "bicycle")
                    .bold()
                Text(content.name)
                ProgressView(value: content.batteryPercentage)
                    .progressViewStyle(.linear)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .font(.caption2)
        }
    }
}

#if os(iOS)
    #Preview("Loaded", as: .accessoryRectangular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }

    #Preview("Error", as: .accessoryRectangular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .error(PreviewError()))
    }
#endif