import Bike
import MapKit
import SwiftUI

/// A thumbnail of a ride. This view is not directly displayed in the interface, but used by `RideThumbnailGenerator``
/// to generate a thumbnail image.
struct RideThumbnailView: View {
    let snapshotImage: OSImage
    let points: [CGPoint]
    let size: CGSize

    var body: some View {
        ZStack {
            Image(osImage: snapshotImage)
                .resizable()
            Canvas { context, _ in
                guard points.count > 1 else { return }

                var path = Path()
                path.move(to: points[0])
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(
                    path,
                    with: .color(.blue),
                    style: StrokeStyle(lineWidth: size.width / 25, lineCap: .round)
                )
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    RideThumbnailView(snapshotImage: .init(resource: .rideThumbnail),
                      points: .rideThumbnailPoints,
                      size: .init(width: 256, height: 256))
}
