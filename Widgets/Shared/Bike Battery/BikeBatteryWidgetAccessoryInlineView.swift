import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetAccessoryInlineView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            Label(formattedContent(content: content), systemImage: "bicycle")
        case .error(let error):
            Text(error.localizedDescription)
        }
    }

    private func formattedContent(content: BikeBatteryWidget.Entry.State.Content) -> String {
        "\(content.name) • \(content.batteryPercentage.formatted(.percent))"
    }
}
