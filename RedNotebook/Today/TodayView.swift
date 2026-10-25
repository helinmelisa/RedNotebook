import SwiftUI
import SwiftData

/// The "1 day 1 page" spread: header, bullets, diary, sticky notes and the quote of the day.
struct TodayView: View {
    @Binding var day: Date

    @Environment(\.modelContext) private var context
    @State private var page: DayPage?
    @State private var selectedSticker: PersistentIdentifier?
    @State private var showingStickers = false
    @State private var turningForward = true

    var body: some View {
        ScrollView {
            // ZStack so the old and new page overlap while one turns over the other
            ZStack(alignment: .top) {
                if let page {
                    DayPageContent(page: page, day: $day, selectedSticker: $selectedSticker,
                                   onAddSticker: { showingStickers = true })
                        // Paper behind the page so it looks solid while turning, lined up with the notebook's grid
                        .background(GridPaper().padding(.leading, -28).padding(.trailing, -44))
                        .id(page.persistentModelID)
                        // The earlier day is always on top: it turns away going forward, and back over going backward
                        .zIndex(-page.day.timeIntervalSinceReferenceDate / 1e9)
                        .transition(.pageTurn(forward: turningForward))
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        // While a sticker is selected, drags move the sticker instead of scrolling
        .scrollDisabled(selectedSticker != nil)
        .overlay(alignment: .bottom) {
            if selectedSticker != nil {
                Button("Done") { withAnimation(.snappy) { selectedSticker = nil } }
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.paper)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(Theme.coverRed))
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
            let next = DayPage.page(for: day, in: context)
            if page == nil {
                page = next
            } else {
                withAnimation(.easeInOut(duration: 0.5)) { page = next }
            }
        }
    }
}

private struct DayPageContent: View {
    @Bindable var page: DayPage
    @Binding var day: Date
    @Binding var selectedSticker: PersistentIdentifier?
    var onAddSticker: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(CalendarStore.self) private var calendarStore
    /// Where the sticky notes strip is, so swiping inside it scrolls the notes instead of flipping the day.
    @State private var notesFrame: CGRect = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            DayHeader(page: page, day: $day, onAddSticker: onAddSticker)

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
                    .lineLimit(6...)
                    .font(Theme.handwriting(size: 22))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.ink)
            }

            PageSection(title: "Today's outfit", color: NotebookSection.stickers.tabColor) {
                OutfitSection(page: page)
            }

            PageSection(title: "What I ate", color: NotebookSection.calendar.tabColor) {
                MealsSection(page: page)
            }

            PageSection(title: "Little notes", color: NotebookSection.today.tabColor) {
                QuickNotesStrip(page: page)
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.space)) } action: { notesFrame = $0 }
            }

            quote
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
        .overlay {
            StickerLayer(page: page, selection: $selectedSticker)
        }
        .coordinateSpace(.named(Self.space))
        .simultaneousGesture(swipeToFlip, including: selectedSticker == nil ? .all : .subviews)
    }

    private static let space = "dayPage"

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
                .font(.system(size: 12, design: .serif).italic())
            Text("— \(quote.author)")
                .font(.system(size: 10, design: .serif))
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
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 1.5).fill(color).frame(width: 14, height: 3)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .serif))
                    .tracking(1.5)
                    .foregroundStyle(Theme.ink.opacity(0.6))
            }
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

/// A page turning over its left edge, like flipping a notebook page.
private struct PageTurn: ViewModifier {
    let angle: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.4)
            .shadow(color: .black.opacity(angle == 0 ? 0 : 0.2), radius: 8, x: 4, y: 0)
    }
}

private extension AnyTransition {
    /// Forward: the old page turns away and the new one is underneath.
    /// Backward: the previous page turns back over the current one.
    static func pageTurn(forward: Bool) -> AnyTransition {
        let turn = AnyTransition.modifier(active: PageTurn(angle: -90), identity: PageTurn(angle: 0))
        let stay = AnyTransition.opacity.animation(.easeInOut(duration: 0.01).delay(0.5))
        return forward
            ? .asymmetric(insertion: .identity, removal: turn)
            : .asymmetric(insertion: turn, removal: stay)
    }
}
