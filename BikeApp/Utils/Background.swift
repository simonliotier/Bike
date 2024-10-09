import MapKit
import SwiftUI

/// Container that ensures that its content is not affected by the depth effet that is usually applied by the system
/// when presenting a sheet.
///
/// We use it to keep the map static when presenting sheets over it.
struct Background<Content: View>: View {
    let content: () -> Content

    @State private var isPresented = false

    var body: some View {
        Color.clear.ignoresSafeArea()
            .task {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isPresented = true
                }
            }
            .fullScreenCover(isPresented: $isPresented) {
                content()
            }
    }
}

#Preview {
    Background {
        Map()
    }
}
