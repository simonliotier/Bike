import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetCircularView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            ZStack {
                ProgressView(value: content.batteryPercentage)
                    .progressViewStyle(.circular)
                Image(systemName: "bicycle")
                    .font(.system(size: 18))
                    .bold()
            }
        case .error:
            Image(systemName: "exclamationmark.octagon.fill")
        }
    }
}

#if os(iOS)
    #Preview("Loaded", as: .accessoryCircular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .loaded(.preview))
    }

    #Preview("Error", as: .accessoryCircular) {
        BikeBatteryWidget()
    } timeline: {
        BikeBatteryWidget.Entry(date: .now, state: .error(PreviewError()))
    }
#endif
