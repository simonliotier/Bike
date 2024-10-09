import Foundation
import SwiftUI

/// Generic view for loading and displaying asynchronously loaded content.
struct AsyncContentView<Content: AsyncContent, ContentView: View>: View {
    let asyncContent: Content
    @ViewBuilder let contentView: (Content.Output) -> ContentView
    @State private var isLoading = false

    var body: some View {
        Group {
            switch asyncContent.state {
            case .loading:
                ProgressView()
            case .failed(let error):
                Text(error.localizedDescription)
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

typealias RefreshAction = () async -> Void

/// Objects implementing this protocol can load content asynchronously.
@MainActor
protocol AsyncContent {
    associatedtype Output
    var state: AsyncContentState<Output> { get }
    func load() async
    func refresh() async
}

extension AsyncContent {
    func refresh() async {
        await load()
    }
}

/// State when loading asynchronous content.
enum AsyncContentState<Value> {
    case loading
    case failed(Error)
    case loaded(Value)
}

class AsyncContentExample: AsyncContent {
    @Published var state: AsyncContentState<String> = .loading

    func load() async {
        state = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.state = .loaded("Example")
        }
    }

    func refresh() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.state = .loaded("Example")
        }
    }
}

struct AsyncContentView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncContentView(asyncContent: AsyncContentExample()) { string in
            List {
                Text(string)
            }
        }
    }
}
