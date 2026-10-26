import PhotosUI
import SwiftUI
import SwiftData

/// The "1 day 1 page" spread: header, bullets, diary, sticky notes and the quote of the day.
struct TodayView: View {
    @Binding var day: Date
    var onDressUp: () -> Void = {}

    @Environment(\.modelContext) private var context
    @State private var page: DayPage?
    @State private var selectedSticker: PersistentIdentifier?
    @State private var showingStickers = false
    @State private var turningForward = true
    @State private var isDrawing = false

    var body: some View {
        ScrollView {
            // ZStack so the old and new page overlap while one turns over the other
            ZStack(alignment: .top) {
                if let page {
                    DayPageContent(page: page, day: $day, selectedSticker: $selectedSticker,
                                   isDrawing: isDrawing, onDressUp: onDressUp)
                        // Its own paper, so the page looks solid while turning and scrolls as one
                        .notebookPage()
                        .id(page.persistentModelID)
                        // The earlier day is always on top: it turns away going forward, and back over going backward
                        .zIndex(-page.day.timeIntervalSinceReferenceDate / 1e9)
                        .transition(.pageTurn(forward: turningForward))
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        // While moving a sticker or drawing, drags belong to the page, not the scroll view
        .scrollDisabled(selectedSticker != nil || isDrawing)
        .overlay(alignment: .bottom) {
            Group {
                if selectedSticker != nil {
                    doneButton { selectedSticker = nil }
                        .padding(.bottom, 20)
                } else if !isDrawing {
                    toolDock
                }
            }
            .padding(.leading, 28)
            .padding(.trailing, 44)
        }
        .overlay(alignment: .topTrailing) {
            // The pen palette covers the bottom of the screen, so "Done" sits at the top,
            // over the day arrows so a stray tap can't flip the page mid-drawing
            if isDrawing {
                doneButton { isDrawing = false }
                    .padding(.top, 24)
                    .padding(.trailing, 44)
            }
        }
        .sheet(isPresented: $showingStickers) {
            StickerDrawer { choice in
                guard let page else { return }
                let placement = page.addSticker(choice, in: context)
                selectedSticker = placement.persistentModelID
            }
        }
        .onChange(of: day) { oldDay, newDay in
            turningForward = newDay > oldDay
        }
        .task(id: day) {
            selectedSticker = nil
            isDrawing = false
            let next = DayPage.page(for: day, in: context)
            if page == nil {
                page = next
            } else {
                SoundEffects.shared.play(.pageTurn)
                withAnimation(.timingCurve(0.45, 0.05, 0.25, 1, duration: 0.6)) { page = next }
            }
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
                selectedSticker = nil
                isDrawing = true
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
        guard let page else { return }
        let placement = page.addSticker(choice, in: context)
        selectedSticker = placement.persistentModelID
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

private struct DayPageContent: View {
    @Bindable var page: DayPage
    @Binding var day: Date
    @Binding var selectedSticker: PersistentIdentifier?
    let isDrawing: Bool
    var onDressUp: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore
    /// Where the sticky notes strip is, so swiping inside it scrolls the notes instead of flipping the day.
    @State private var notesFrame: CGRect = .zero
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
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.space)) } action: { notesFrame = $0 }
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
            DrawingCanvas(data: $page.drawing, isActive: isDrawing)
        }
        .overlay {
            StickerLayer(page: page, selection: $selectedSticker)
                .allowsHitTesting(!isDrawing)
        }
        .coordinateSpace(.named(Self.space))
        .sheet(item: $countdownSheet) { sheet in
            switch sheet {
            case .new: CountdownEditor(countdown: nil)
            case .edit(let countdown): CountdownEditor(countdown: countdown)
            }
        }
        .simultaneousGesture(swipeToFlip, including: selectedSticker == nil && !isDrawing ? .all : .subviews)
    }

    private static let space = "dayPage"

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

    /// Swipe left for the next day, right for the previous one.
    private var swipeToFlip: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .named(Self.space))
            .onEnded { value in
                let dx = value.translation.width, dy = value.translation.height
                guard abs(dx) > 80, abs(dx) > abs(dy) * 2,
                      !notesFrame.contains(value.startLocation),
                      let target = Calendar.current.date(byAdding: .day, value: dx < 0 ? 1 : -1, to: day) else { return }
                UISelectionFeedbackGenerator().selectionChanged()
                day = target
            }
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

#Preview {
    @Previewable @State var day = Date.now
    ZStack {
        GridPaper().ignoresSafeArea()
        TodayView(day: $day)
            .padding(.horizontal, 24)
    }
    .modelContainer(SampleData.container)
    .environment(CalendarStore())
}

/// A page turning over its left edge, like flipping a notebook page: it lifts, catches the light along its
/// bending edge and darkens as it turns away.
private struct PageTurn: ViewModifier, Animatable {
    /// 0 lying flat, 1 fully turned.
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let lift = sin(progress * .pi) // most lifted halfway through
        content
            // Paper shading: darker towards the free edge as it turns away from the light
            .overlay {
                LinearGradient(colors: [.black.opacity(0.04 * progress), .black.opacity(0.32 * progress)],
                               startPoint: .leading, endPoint: .trailing)
                    .allowsHitTesting(false)
            }
            // The curl: a soft highlight along the bending edge
            .overlay(alignment: .trailing) {
                LinearGradient(colors: [.clear, .white.opacity(0.5 * lift), .black.opacity(0.12 * lift)],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(width: 46)
                    .allowsHitTesting(false)
            }
            .rotation3DEffect(.degrees(-92 * progress), axis: (x: 0.015 * lift, y: 1, z: 0),
                              anchor: .leading, perspective: 0.55)
            .offset(y: -6 * lift)
            .shadow(color: .black.opacity(0.28 * lift), radius: 14 * lift, x: 10 * lift, y: 6 * lift)
    }
}

/// The page underneath, in the shadow of the page turning over it.
private struct UnderTurningPage: ViewModifier, Animatable {
    /// 1 fully covered, 0 uncovered.
    var shade: Double

    var animatableData: Double {
        get { shade }
        set { shade = newValue }
    }

    func body(content: Content) -> some View {
        content.overlay {
            LinearGradient(colors: [.black.opacity(0.22 * shade), .black.opacity(0.05 * shade), .clear],
                           startPoint: .leading, endPoint: .trailing)
                .allowsHitTesting(false)
        }
    }
}

private extension AnyTransition {
    /// Forward: the old page turns away, uncovering the new one.
    /// Backward: the previous page turns back over the current one.
    static func pageTurn(forward: Bool) -> AnyTransition {
        let turn = AnyTransition.modifier(active: PageTurn(progress: 1), identity: PageTurn(progress: 0))
        let underneath = AnyTransition.modifier(active: UnderTurningPage(shade: 1), identity: UnderTurningPage(shade: 0))
        let stay = AnyTransition.opacity.animation(.easeInOut(duration: 0.01).delay(0.6))
        return forward
            ? .asymmetric(insertion: underneath, removal: turn)
            : .asymmetric(insertion: turn, removal: underneath.combined(with: stay))
    }
}
