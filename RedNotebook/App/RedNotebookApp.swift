import SwiftUI
import SwiftData

@main
struct RedNotebookApp: App {
    @State private var calendarStore = CalendarStore()

    init() {
        Theme.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(calendarStore)
        }
        .modelContainer(for: [DayPage.self, PhotoSticker.self, ClothingItem.self, BodyPhoto.self])
    }
}

/// Shows the closed cover, and the notebook pages once it has been opened.
struct RootView: View {
    /// Launch with `--open` to skip the cover (handy for previews and screenshots).
    @State private var isOpen = ProcessInfo.processInfo.arguments.contains("--open")
    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore
    /// Picking a new cover colour redraws the whole notebook in it.
    @AppStorage(CoverColor.storageKey) private var coverColor = CoverColor.red.rawValue
    @AppStorage(AppLock.enabledKey) private var isLocked = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            DeskBackground()

            if isOpen {
                NotebookView(onClose: { withAnimation(.easeInOut(duration: 0.4)) { isOpen = false } })
                    .transition(.opacity)
            } else {
                NotebookCoverView(onOpen: { isOpen = true })
                    .transition(.opacity)
            }
        }
        // Locked notebooks hide their pages in the app switcher and close when you leave
        .overlay {
            if isLocked && isOpen && scenePhase != .active {
                ZStack {
                    DeskBackground()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.inkTertiary)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background && isLocked { isOpen = false }
        }
        .id(coverColor)
        // A paper notebook looks the same in Dark Mode; the cover's colour instead of iOS blue for controls
        .preferredColorScheme(.light)
        .tint(Theme.accent)
        #if DEBUG
        .task {
            if ProcessInfo.processInfo.arguments.contains("--sample-data") {
                SampleData.fill(context)
                SampleData.fillCloset(context)
                await SampleData.fillCalendar(calendarStore)
            }
        }
        #endif
    }
}
