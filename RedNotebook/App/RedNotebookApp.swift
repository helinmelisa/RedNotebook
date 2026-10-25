import SwiftUI
import SwiftData

@main
struct RedNotebookApp: App {
    @State private var calendarStore = CalendarStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(calendarStore)
        }
        .modelContainer(for: [DayPage.self, PhotoSticker.self])
    }
}

/// Shows the closed cover, and the notebook pages once it has been opened.
struct RootView: View {
    /// Launch with `--open` to skip the cover (handy for previews and screenshots).
    @State private var isOpen = ProcessInfo.processInfo.arguments.contains("--open")
    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore

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
        #if DEBUG
        .task {
            if ProcessInfo.processInfo.arguments.contains("--sample-data") {
                SampleData.fill(context)
                await SampleData.fillCalendar(calendarStore)
            }
        }
        #endif
    }
}
