import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetInlineView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            Label("\(content.name) • \(content.batteryPercentage.formatted(.percent))", systemImage: "bicycle")
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}

#if os(iOS)
    #Preview("Loaded", as: .accessoryInline) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }

    #Preview("Error", as: .accessoryInline) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .error(PreviewError()))
    }
#endif
