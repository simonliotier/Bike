import SwiftUI
import WidgetKit

struct BikeMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.5), lineWidth: 1.0)
                .fill(.green.opacity(0.35))
                .frame(width: 20, height: 20)
                .foregroundStyle(.green.opacity(0.2))
            Image(.marker)
                .offset(.init(width: 0, height: -36))
                .unredacted()
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        BikeMarker()
            .containerBackground(.fill.tertiary, for: .widget)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
