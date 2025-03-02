import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetAccessoryCornerView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case let .loaded(content):
            Text(content.batteryPercentage.formatted(.percent))
                .widgetCurvesContent()
                .widgetLabel {
                    ProgressView(value: content.batteryPercentage)
                }
        case .error:
            Image(systemName: "exclamationmark.octagon.fill")
        }
    }
}
