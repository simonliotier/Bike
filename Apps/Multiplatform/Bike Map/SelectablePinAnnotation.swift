import Bike
import MapKit
import SwiftUI

/// A map annotation that transforms into a pin when selected, like in the "Find My" app.
struct SelectablePinAnnotation: View {
    /// Image resource displayed by the annotation.
    let resource: ImageResource

    let pinTransformationEnabled: Bool

    @Binding var isSelected: Bool

    var isPinVisible: Bool {
        if pinTransformationEnabled {
            isSelected
        } else {
            false
        }
    }

    private let annotationSize = CGSize(width: 40, height: 40)
    private let selectedAnnotationSize = CGSize(width: 8, height: 8)

    var body: some View {
        ZStack {
            Circle()
                .fill(.pin)
            Image(resource)
                .resizable()
                .clipShape(Circle())
                .opacity(isPinVisible ? 0 : 1)
                .overlay(content: {
                    Circle()
                        .stroke(.secondary.opacity(0.2), lineWidth: isSelected ? 1 : 2)
                })
        }
        .frame(width: isPinVisible ? selectedAnnotationSize.width : annotationSize.width,
               height: isPinVisible ? selectedAnnotationSize.height : annotationSize.height)
        .shadow(color: Color.black.opacity(0.3), radius: 6, y: 3)
        .background {
            Pin(resource: resource)
                .offset(y: -12)
                .scaleEffect(isPinVisible ? CGSize(width: 1, height: 1) : .zero)
        }
        // Ensure that the annotation remains at the same size whether selected or not.
        .frame(width: annotationSize.width, height: annotationSize.height)
        .padding(.horizontal, 8)
    }
}

#Preview {
    @Previewable @State var isSelected = true

    ZStack {
        Map()
        SelectablePinAnnotation(resource: .bike, pinTransformationEnabled: true, isSelected: $isSelected)
    }
    .overlay(alignment: .bottom) {
        Button(isSelected ? "Deselect" : "Select") {
            withAnimation(.bouncy) {
                isSelected.toggle()
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
