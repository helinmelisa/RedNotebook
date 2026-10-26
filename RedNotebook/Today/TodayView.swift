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
    /// Optional parts opened from "Add to this page" (parts with something in them always show).
    @State private var opened: Set<Part> = []
    /// Showing a remove button beside each part.
    @State private var isArranging = false
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

    /// The parts of a day page. Any of them can be taken off a busy day and put back from "Add to this page".
    enum Part: String, CaseIterable {
        case habits, countdowns, tasks, diary, outfit, meals, notes, memories, word

        /// Only on the page once you add them (or write in them).
        var isOptional: Bool { [.outfit, .meals, .notes].contains(self) }

        var title: String {
            switch self {
            case .habits: "Habits"
            case .countdowns: "Countdown"
            case .tasks: "Tasks"
            case .diary: "Diary"
            case .outfit: "Outfit"
            case .meals: "What I ate"
            case .notes: "Note"
            case .memories: "On this day"
            case .word: "Portuguese word"
            }
        }

        var icon: String {
            switch self {
            case .habits: "checkmark.circle"
            case .countdowns: "hourglass"
            case .tasks: "checklist"
            case .diary: "book.closed"
            case .outfit: "hanger"
            case .meals: "fork.knife"
            case .notes: "note.text"
            case .memories: "clock.arrow.circlepath"
            case .word: "character.book.closed"
            }
        }
    }

    private func isShown(_ part: Part) -> Bool {
        if page.hiddenParts.contains(part.rawValue) { return false }
        if !part.isOptional || opened.contains(part) { return true }
        switch part {
        case .outfit: return !page.wornItems.isEmpty || page.outfitPhoto != nil || !page.outfitNote.isEmpty
        case .meals: return !(page.meals ?? []).isEmpty || ![page.breakfast, page.lunch, page.dinner, page.snacks].allSatisfy(\.isEmpty)
        case .notes: return !(page.notes ?? []).isEmpty
        default: return true
        }
    }

    /// Takes a part off this day's page (what's written in it is kept).
    private func remove(_ part: Part) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.snappy) {
            page.hiddenParts.append(part.rawValue)
            opened.remove(part)
        }
    }

    private func putBack(_ part: Part) {
        UISelectionFeedbackGenerator().selectionChanged()
        withAnimation(.snappy) {
            page.hiddenParts.removeAll { $0 == part.rawValue }
            if part.isOptional { opened.insert(part) }
        }
        if part == .notes && (page.notes ?? []).isEmpty {
            QuickNote(colorIndex: 0).page = page
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
            DayHeader(page: page, day: $day)

            if isShown(.habits) {
                HabitRow(page: page).removable(isArranging) { remove(.habits) }
            }

            if isShown(.countdowns) {
                CountdownStrip(day: page.day, onAdd: { countdownSheet = .new }, onEdit: { countdownSheet = .edit($0) })
                    .removable(isArranging && hasUpcomingCountdown) { remove(.countdowns) }
            }

            if isShown(.tasks) {
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
                .removable(isArranging) { remove(.tasks) }
            }

            if isShown(.diary) {
                PageSection(title: "Diary", color: NotebookSection.diary.tabColor) {
                    TextField("Dear diary…", text: $page.diaryText, axis: .vertical)
                        .lineLimit(3...)
                        .font(Theme.handwriting(size: 22))
                        .lineSpacing(2)
                        .foregroundStyle(Theme.ink)

                    DailyPromptCard(page: page)
                        .padding(.top, 6)
                }
                .removable(isArranging) { remove(.diary) }
            }

            if isShown(.outfit) {
                PageSection(title: "Today's outfit", color: NotebookSection.stickers.tabColor) {
                    OutfitSection(page: page, onDressUp: onDressUp)
                }
                .removable(isArranging) { remove(.outfit) }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isShown(.meals) {
                PageSection(title: "What I ate", color: NotebookSection.calendar.tabColor) {
                    MealsSection(page: page)
                }
                .removable(isArranging) { remove(.meals) }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isShown(.notes) {
                PageSection(title: "Little notes", color: NotebookSection.today.tabColor) {
                    QuickNotesStrip(page: page)
                }
                .removable(isArranging) { remove(.notes) }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            addToPage

            if isShown(.memories) {
                OnThisDay(day: page.day) { day = $0 }
                    .removable(isArranging) { remove(.memories) }
            }

            if isShown(.word) {
                PortugueseWordCard(day: page.day)
                    .removable(isArranging) { remove(.word) }
            }

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

    /// Chips for the parts this page doesn't have, so new pages stay short and calm,
    /// and a way to take parts off a busy day.
    private var addToPage: some View {
        let missing = Part.allCases.filter { !isShown($0) }
        return VStack(alignment: .leading, spacing: 8) {
            Text("ADD TO THIS PAGE")
                .font(Theme.eyebrow)
                .tracking(1.5)
                .foregroundStyle(Theme.inkTertiary)
            FlowLayout(spacing: 8) {
                ForEach(missing, id: \.self) { part in
                    Button { putBack(part) } label: {
                        chipLabel(part.title, systemImage: part.icon)
                    }
                    .buttonStyle(.plain)
                }
                if isShown(.countdowns) && !hasUpcomingCountdown {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        countdownSheet = .new
                    } label: {
                        chipLabel("Countdown", systemImage: "hourglass")
                    }
                    .buttonStyle(.plain)
                }
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.snappy) { isArranging.toggle() }
                } label: {
                    Label(isArranging ? "Done" : "Remove parts", systemImage: isArranging ? "checkmark" : "minus.circle")
                        .font(Theme.serif(13, isArranging ? .semibold : .regular))
                        .foregroundStyle(isArranging ? Theme.paper : Theme.inkTertiary)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(isArranging ? Theme.accent : .clear))
                }
                .buttonStyle(.plain)
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

private extension View {
    /// While arranging the page: a red "−" in the margin beside the part, to take it off this day.
    func removable(_ isArranging: Bool, onRemove: @escaping () -> Void) -> some View {
        overlay(alignment: .topTrailing) {
            if isArranging {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Theme.red)
                        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                }
                .buttonStyle(.plain)
                .offset(x: 33, y: -3) // out in the right margin
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Remove from this page")
            }
        }
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
