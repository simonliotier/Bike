import SwiftUI
import WidgetKit

@main
struct BikeBatteryWidgetWatch: Widget {
    var body: some WidgetConfiguration {
        BikeBatteryWidget().body
            .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        [
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline
        ]
    }
}

#Preview("Accessory Circular", as: .accessoryCircular) {
    BikeBatteryWidgetWatch()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#Preview("Accessory Corner", as: .accessoryCorner) {
    BikeBatteryWidgetWatch()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#Preview("Accessory Rectangular", as: .accessoryRectangular) {
    BikeBatteryWidgetWatch()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#Preview("Accessory Inline", as: .accessoryInline) {
    BikeBatteryWidgetWatch()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}
