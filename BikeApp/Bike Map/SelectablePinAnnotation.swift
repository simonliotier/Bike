import Bike
import MapKit
import SwiftUI

/// A map annotation that transforms into a pin when selected, like in the "Find My" app.
struct SelectablePinAnnotation: View {
    /// Image resource displayed by the annotation.
    let resource: ImageResource

    @Binding var isSelected: Bool

    private let annotationSize = CGSize(width: 40, height: 40)
    private let selectedAnnotationSize = CGSize(width: 8, height: 8)

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.pin)
            Image(resource)
                .resizable()
                .clipShape(Circle())
                .opacity(isSelected ? 0 : 1)
                .overlay(content: {
                    Circle()
                        .stroke(.secondary.opacity(0.2), lineWidth: isSelected ? 1 : 2)
                })
        }
        .frame(width: isSelected ? selectedAnnotationSize.width : annotationSize.width,
               height: isSelected ? selectedAnnotationSize.height : annotationSize.height)
        .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)
        .background {
            Pin(resource: resource)
                .offset(y: -12)
                .scaleEffect(isSelected ? CGSize(width: 1, height: 1) : .zero)
        }
        // Ensure that the annotation remains at the same size whether selected or not.
        .frame(width: annotationSize.width, height: annotationSize.height)
    }
}

#Preview {
    @Previewable @State var isSelected: Bool = false

    ZStack {
        Map()
        VStack {
            SelectablePinAnnotation(resource: .bike, isSelected: $isSelected)
                .safeAreaInset(edge: .bottom) {
                    Button(isSelected ? "Deselect" : "Select") {
                        withAnimation(.bouncy) {
                            isSelected.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
        }
    }
}
