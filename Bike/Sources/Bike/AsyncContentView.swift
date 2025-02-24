import Foundation
import SwiftUI

/// Generic view for loading and displaying asynchronously loaded content.
public struct AsyncContentView<Content: AsyncContent, ContentView: View>: View {
    @State var asyncContent: Content
    @ViewBuilder let contentView: (Content.Output) -> ContentView
    @State private var isLoading = false

    public init(asyncContent: Content, contentView: @escaping (Content.Output) -> ContentView) {
        self.asyncContent = asyncContent
        self.contentView = contentView
    }

    public var body: some View {
        Group {
            switch asyncContent.state {
            case .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)
            case .failed(let error):
                Text(error.localizedDescription)
                    .frame(maxHeight: .infinity)
            case .loaded(let output):
                contentView(output)
            }
        }
        .task {
            if isLoading {
                return
            }

            self.isLoading = true
            await asyncContent.load()
        }
    }
}

/// Objects implementing this protocol can load content asynchronously.
@MainActor
public protocol AsyncContent {
    associatedtype Output
    var state: AsyncContentState<Output> { get }
    func load() async
}

/// State when loading asynchronous content.
public enum AsyncContentState<Value> {
    case loading
    case failed(Error)
    case loaded(Value)
}

class AsyncContentExample: AsyncContent {
    @Published var state: AsyncContentState<String> = .loading

    func load() async {
        state = .loading
        try? await Task.sleep(for: .seconds(2))
        state = .loaded("Example")
    }
}

#Preview {
    AsyncContentView(asyncContent: AsyncContentExample()) { string in
        List {
            Text(string)
        }
    }
}
