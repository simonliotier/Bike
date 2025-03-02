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
            BikeBatteryWidgetAccessoryCircularView(entry: entry)
        case .accessoryCorner:
            BikeBatteryWidgetAccessoryCornerView(entry: entry)
        case .accessoryInline:
            BikeBatteryWidgetAccessoryInlineView(entry: entry)
        case .accessoryRectangular:
            BikeBatteryWidgetAccessoryRectangularView(entry: entry)
        default: EmptyView()
        }
    }
}
