import PhotosUI
import SwiftUI
import SwiftData

/// What the tools are doing on the open page, shared between the page and the tool dock around it.
@Observable
final class PageTools {
    var selectedSticker: PersistentIdentifier?
    var isDrawing = false

    /// Moving a sticker or drawing: drags belong to the page, so it neither scrolls nor turns.
    var isBusy: Bool { selectedSticker != nil || isDrawing }
}

/// The "1 day 1 page" spread: header, bullets, diary, sticky notes and the quote of the day.
/// Turn the pages with a finger, like the real notebook.
struct TodayView: View {
    @Binding var day: Date
    var onDressUp: () -> Void = {}

    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore
    @State private var tools = PageTools()
    @State private var showingStickers = false

    var body: some View {
        CurlingPages(day: $day, isLocked: tools.isBusy) { pageDay in
            DayPageScroll(page: DayPage.page(for: pageDay, in: context), day: $day, tools: tools, onDressUp: onDressUp)
                // Each page lives in its own UIKit host, so it gets the notebook's environment handed over
                .modelContext(context)
                .environment(calendarStore)
                .tint(Theme.accent)
        }
        .overlay(alignment: .bottom) {
            Group {
                if tools.selectedSticker != nil {
                    doneButton { tools.selectedSticker = nil }
                        .padding(.bottom, 20)
                } else if !tools.isDrawing {
                    toolDock
                }
            }
            .padding(.leading, 28)
            .padding(.trailing, 44)
        }
        .overlay(alignment: .topTrailing) {
            // The pen palette covers the bottom of the screen, so "Done" sits at the top,
            // over the day arrows so a stray tap can't flip the page mid-drawing
            if tools.isDrawing {
                doneButton { tools.isDrawing = false }
                    .padding(.top, 24)
                    .padding(.trailing, 44)
            }
        }
        .sheet(isPresented: $showingStickers) {
            StickerDrawer { choice in
                let placement = DayPage.page(for: day, in: context).addSticker(choice, in: context)
                tools.selectedSticker = placement.persistentModelID
            }
        }
        .onChange(of: day) {
            tools.selectedSticker = nil
            tools.isDrawing = false
        }
    }

    /// Floating tools for decorating the page: stickers, a photo of the day and the pen.
    private var toolDock: some View {
        HStack(spacing: 4) {
            dockButton("star.bubble", label: "Add sticker") { showingStickers = true }
            Rectangle().fill(Theme.hairline).frame(width: 1, height: 20)
            PhotoFramePicker(onPick: addPhotos) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 40, height: 36)
            }
            .accessibilityLabel("Add photos of the day")
            Rectangle().fill(Theme.hairline).frame(width: 1, height: 20)
            dockButton("pencil.tip", label: "Draw") {
                tools.selectedSticker = nil
                tools.isDrawing = true
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Capsule().fill(Theme.paper))
        .overlay(Capsule().stroke(Theme.hairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom, 18)
        .transition(.scale(scale: 0.8).combined(with: .opacity))
    }

    /// Framed photos of the day land on the page, selected so a caption can be written on them.
    private func addPhotos(_ choice: StickerChoice) {
        let placement = DayPage.page(for: day, in: context).addSticker(choice, in: context)
        tools.selectedSticker = placement.persistentModelID
    }

    private func dockButton(_ systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.snappy) { action() }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.ink)
                .frame(width: 40, height: 36)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func doneButton(_ action: @escaping () -> Void) -> some View {
        Button("Done") { withAnimation(.snappy) { action() } }
            .font(Theme.serif(14, .semibold))
            .foregroundStyle(Theme.paper)
            .padding(.horizontal, 22)
            .padding(.vertical, 9)
            .background(Capsule().fill(Theme.accent))
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

/// One day's page, scrolling on its own paper.
private struct DayPageScroll: View {
    let page: DayPage
    @Binding var day: Date
    let tools: PageTools
    var onDressUp: () -> Void

    var body: some View {
        ScrollView {
            DayPageContent(page: page, day: $day, tools: tools, onDressUp: onDressUp)
                .notebookPage()
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .scrollDisabled(tools.isBusy)
    }
}

private struct DayPageContent: View {
    @Bindable var page: DayPage
    @Binding var day: Date
    @Bindable var tools: PageTools
    var onDressUp: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore
    /// Optional sections opened from "Add to this page" (sections with something in them always show).
    @State private var opened: Set<OptionalSection> = []
    @State private var countdownSheet: CountdownSheet?
    @AppStorage(Countdown.storageKey) private var countdownsRaw = ""

    enum CountdownSheet: Identifiable {
        case new, edit(Countdown)
        var id: String {
            switch self {
            case .new: "new"
            case .edit(let countdown): countdown.id
            }
        }
    }

    private var hasUpcomingCountdown: Bool {
        Countdown.list(from: countdownsRaw).contains { $0.daysLeft(from: page.day) >= 0 }
    }

    enum OptionalSection: CaseIterable {
        case outfit, meals, notes

        var title: String {
            switch self {
            case .outfit: "Outfit"
            case .meals: "What I ate"
            case .notes: "Note"
            }
        }

        var icon: String {
            switch self {
            case .outfit: "hanger"
            case .meals: "fork.knife"
            case .notes: "note.text"
            }
        }
    }

    private func isShown(_ section: OptionalSection) -> Bool {
        if opened.contains(section) { return true }
        switch section {
        case .outfit: return !page.wornItems.isEmpty || page.outfitPhoto != nil || !page.outfitNote.isEmpty
        case .meals: return !(page.meals ?? []).isEmpty || ![page.breakfast, page.lunch, page.dinner, page.snacks].allSatisfy(\.isEmpty)
        case .notes: return !(page.notes ?? []).isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
            DayHeader(page: page, day: $day)

            HabitRow(page: page)

            CountdownStrip(day: page.day, onAdd: { countdownSheet = .new }, onEdit: { countdownSheet = .edit($0) })

            PageSection(title: "Tasks & events", color: NotebookSection.todo.tabColor) {
                // Holiday and iPhone Calendar events first, then the notebook's own bullets
                if let holiday = PortugueseHolidays.holiday(on: page.day) {
                    HolidayLine(holiday: holiday)
                }
                ForEach(calendarStore.events(on: page.day), id: \.calendarItemIdentifier) { event in
                    EventLine(event: event)
                }
                BulletList(page: page, onMigrate: migrate)
            }

            PageSection(title: "Diary", color: NotebookSection.diary.tabColor) {
                TextField("Dear diary…", text: $page.diaryText, axis: .vertical)
                    .lineLimit(3...)
                    .font(Theme.handwriting(size: 22))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.ink)

                DailyPromptCard(page: page)
                    .padding(.top, 6)
            }

            if isShown(.outfit) {
                PageSection(title: "Today's outfit", color: NotebookSection.stickers.tabColor) {
                    OutfitSection(page: page, onDressUp: onDressUp)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isShown(.meals) {
                PageSection(title: "What I ate", color: NotebookSection.calendar.tabColor) {
                    MealsSection(page: page)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isShown(.notes) {
                PageSection(title: "Little notes", color: NotebookSection.today.tabColor) {
                    QuickNotesStrip(page: page)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            addToPage

            OnThisDay(day: page.day) { day = $0 }

            PortugueseWordCard(day: page.day)

            quote
        }
        .padding(.top, 20)
        .padding(.bottom, 80)
        .overlay {
            // Drawing sits under the stickers, like ink under something stuck on the page
            DrawingCanvas(data: $page.drawing, isActive: tools.isDrawing && Calendar.current.isDate(page.day, inSameDayAs: day))
        }
        .overlay {
            StickerLayer(page: page, selection: $tools.selectedSticker)
                .allowsHitTesting(!tools.isDrawing)
        }
        .sheet(item: $countdownSheet) { sheet in
            switch sheet {
            case .new: CountdownEditor(countdown: nil)
            case .edit(let countdown): CountdownEditor(countdown: countdown)
            }
        }
    }

    /// Chips for the sections this page doesn't use yet, so new pages stay short and calm.
    @ViewBuilder
    private var addToPage: some View {
        let hidden = OptionalSection.allCases.filter { !isShown($0) }
        if !hidden.isEmpty || !hasUpcomingCountdown {
            VStack(alignment: .leading, spacing: 8) {
                Text("ADD TO THIS PAGE")
                    .font(Theme.eyebrow)
                    .tracking(1.5)
                    .foregroundStyle(Theme.inkTertiary)
                FlowLayout(spacing: 8) {
                    ForEach(hidden, id: \.self) { section in
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            _ = withAnimation(.snappy) { opened.insert(section) }
                            if section == .notes {
                                QuickNote(colorIndex: 0).page = page
                            }
                        } label: {
                            chipLabel(section.title, systemImage: section.icon)
                        }
                        .buttonStyle(.plain)
                    }
                    if !hasUpcomingCountdown {
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            countdownSheet = .new
                        } label: {
                            chipLabel("Countdown", systemImage: "hourglass")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func chipLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(Theme.serif(13))
            .foregroundStyle(Theme.inkSecondary)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Capsule().strokeBorder(Theme.hairline, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
    }

    private var quote: some View {
        let quote = DailyQuote.quote(for: page.day)
        return VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(Theme.ink.opacity(0.15)).frame(height: 0.5)
            Text("“\(quote.text)”")
                .font(Theme.serif(12).italic())
            Text("— \(quote.author)")
                .font(Theme.serif(10))
        }
        .foregroundStyle(Theme.ink.opacity(0.55))
        .padding(.top, 10)
    }

    /// Bullet journal migration: mark the task `>` and copy it to tomorrow's page.
    private func migrate(_ item: BulletItem) {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: page.day) else { return }
        item.schedule(on: tomorrow, in: context)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// A small coloured label followed by the section's content.
private struct PageSection<Content: View>: View {
    let title: String
    let color: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title, color: color)
            content
        }
    }
}
