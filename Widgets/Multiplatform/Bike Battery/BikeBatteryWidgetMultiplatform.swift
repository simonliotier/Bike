import SwiftUI
import WidgetKit

struct BikeBatteryWidgetMultiplatform: Widget {
    var body: some WidgetConfiguration {
        BikeBatteryWidget().body
            .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        return [.systemSmall,
                .accessoryCircular,
                .accessoryRectangular,
                .accessoryInline]
        #endif

        #if os(macOS)
        return [.systemSmall]
        #endif
    }
}

#Preview("System Small", as: .systemSmall) {
    BikeBatteryWidgetMultiplatform()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#if os(iOS)
#Preview("Accessory Circular", as: .accessoryCircular) {
    BikeBatteryWidgetMultiplatform()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#Preview("Accessory Rectangular", as: .accessoryRectangular) {
    BikeBatteryWidgetMultiplatform()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}

#Preview("Accessory Inline", as: .accessoryInline) {
    BikeBatteryWidgetMultiplatform()
} timeline: {
    BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
}
#endif
