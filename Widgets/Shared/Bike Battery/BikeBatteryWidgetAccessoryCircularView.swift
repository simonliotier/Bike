import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetAccessoryCircularView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            ZStack {
                ProgressView(value: content.batteryPercentage)
                    .progressViewStyle(.circular)
                Image(systemName: "bicycle")
                    .bold()
            }
        case .error:
            Image(systemName: "exclamationmark.octagon.fill")
        }
    }
}
