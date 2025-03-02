import Foundation
import SwiftUI
import WidgetKit

struct BikeBatteryWidgetSystemView: View {
    var entry: BikeBatteryWidget.Entry

    var body: some View {
        switch entry.state {
        case .loaded(let content):
            VStack(alignment: .leading) {
                ZStack {
                    ProgressView(value: Double(content.batteryPercentage))
                        .progressViewStyle(.circular)
                        .tint(.white)

                    Image(systemName: "bicycle")
                        .font(.system(size: 18))
                        .bold()
                }
                .frame(height: 62)

                Spacer()

                Text(content.batteryPercentage.formatted(.percent))
                    .font(.system(size: 40))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .padding()
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundStyle(.white)
                .padding()
        }
    }
}
