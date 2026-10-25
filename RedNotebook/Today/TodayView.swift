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
    @State private var polaroidItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            // ZStack so the old and new page overlap while one turns over the other
            ZStack(alignment: .top) {
                if let page {
                    DayPageContent(page: page, day: $day, selectedSticker: $selectedSticker,
                                   isDrawing: isDrawing, onDressUp: onDressUp)
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
        // While moving a sticker or drawing, drags belong to the page, not the scroll view
        .scrollDisabled(selectedSticker != nil || isDrawing)
        .overlay(alignment: .bottom) {
            if selectedSticker != nil {
                doneButton { selectedSticker = nil }
                    .padding(.bottom, 20)
            } else if !isDrawing {
                toolDock
            }
        }
        .overlay(alignment: .topTrailing) {
            // The pen palette covers the bottom of the screen, so "Done" sits at the top,
            // over the day arrows so a stray tap can't flip the page mid-drawing
            if isDrawing {
                doneButton { isDrawing = false }
                    .padding(.top, 24)
            }
        }
        .sheet(isPresented: $showingStickers) {
            StickerDrawer { choice in
                guard let page else { return }
                let placement = page.addSticker(choice, in: context)
                selectedSticker = placement.persistentModelID
            }
        }
        .onChange(of: polaroidItem) { _, item in
            guard let item else { return }
            Task { await addPolaroid(from: item) }
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
                withAnimation(.easeInOut(duration: 0.5)) { page = next }
            }
        }
    }

    /// Floating tools for decorating the page: stickers, a photo of the day and the pen.
    private var toolDock: some View {
        HStack(spacing: 4) {
            dockButton("star.bubble", label: "Add sticker") { showingStickers = true }
            Rectangle().fill(Theme.hairline).frame(width: 1, height: 20)
            PhotosPicker(selection: $polaroidItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 40, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a photo of the day")
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

    /// A photo of the day lands on the page as a polaroid, selected so a caption can be written on it.
    private func addPolaroid(from item: PhotosPickerItem) async {
        defer { polaroidItem = nil }
        guard let page,
              let data = try? await item.loadTransferable(type: Data.self),
              let jpeg = await PhotoCutout.polaroidPhoto(from: data) else { return }
        let placement = page.addSticker(.polaroid(jpeg), in: context)
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

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
            DayHeader(page: page, day: $day)

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
                OutfitSection(page: page, onDressUp: onDressUp)
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
        .simultaneousGesture(swipeToFlip, including: selectedSticker == nil && !isDrawing ? .all : .subviews)
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
