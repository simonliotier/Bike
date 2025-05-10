#if !os(tvOS)
import SwiftUI

/// View presenting its content as a sheet, without animation when the view appears. It is useful to preview a view
/// designed to be displayed in a sheet.
struct SheetPreview<Content: View>: View {
    let content: () -> Content

    @State private var isPresented = false

    var body: some View {
        Color.primary.ignoresSafeArea()
            .task {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isPresented = true
                }
            }
            .popover(isPresented: $isPresented, attachmentAnchor: .point(.center), arrowEdge: .trailing) {
                content()
            }
    }
}
#endif
