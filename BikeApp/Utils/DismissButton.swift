import SwiftUI

/// A button that dismisses the current presentation.
///
/// This button mimics the "􀁡" button used in sheets in many Apple apps.
struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "multiply")
                .font(.headline)
        }
        .tint(.secondary)
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .frame(width: 30, height: 30)
        .accessibilityLabel("Close")
    }
}
