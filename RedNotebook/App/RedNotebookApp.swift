import SwiftUI

@main
struct RedNotebookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Shows the closed cover, and the notebook pages once it has been opened.
struct RootView: View {
    /// Launch with `--open` to skip the cover (handy for previews and screenshots).
    @State private var isOpen = ProcessInfo.processInfo.arguments.contains("--open")

    var body: some View {
        ZStack {
            Theme.desk.ignoresSafeArea()

            if isOpen {
                NotebookView(onClose: { withAnimation(.easeInOut(duration: 0.4)) { isOpen = false } })
                    .transition(.opacity)
            } else {
                NotebookCoverView(onOpen: { isOpen = true })
                    .transition(.opacity)
            }
        }
    }
}
