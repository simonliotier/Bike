import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetView: View {
    var entry: BikeBatteryWidget.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            BikeBatteryWidgetSystemView(entry: entry)
        case .accessoryCircular:
            BikeBatteryWidgetCircularView(entry: entry)
        case .accessoryInline:
            BikeBatteryWidgetInlineView(entry: entry)
        case .accessoryRectangular:
            BikeBatteryWidgetRectangularView(entry: entry)
        default: EmptyView()
        }
    }
}
