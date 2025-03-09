import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetAccessoryCornerView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case let .loaded(content):
            #if !os(macOS)
            Text(content.batteryPercentage.formatted(.percent))
                .widgetCurvesContent()
                .widgetLabel {
                    ProgressView(value: content.batteryPercentage)
                }
            #endif
        case .error:
            Image(systemName: "exclamationmark.octagon.fill")
        }
    }
}
