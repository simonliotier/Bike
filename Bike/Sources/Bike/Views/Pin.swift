import MapKit
import SwiftUI

/// A pin displaying an image, to be displayed on a map.
public struct Pin: View {
    /// Image resource displayed in the pin.
    public let resource: ImageResource

    public init(resource: ImageResource = .bike) {
        self.resource = resource
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Image(.pin)
                .renderingMode(.template)
                .foregroundStyle(Color(.pin))
            Image(resource)
                .resizable()
                .clipShape(Circle())
                .frame(width: 56, height: 56)
                .offset(y: 3)
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        .visualEffect { content, proxy in
            // Make the pin points to the center of the view.
            content.offset(y: -proxy.size.height / 2.0)
        }
    }
}

#Preview {
    ZStack {
        Map()
        Circle()
            .fill(.red)
            .frame(width: 10, height: 10, alignment: .center)
        Pin(resource: .elops920E)
    }
}

public extension ImageResource {
    static let bike = ImageResource.elops920E
}

public extension Color {
    static let pin = Color(.pin)
}
