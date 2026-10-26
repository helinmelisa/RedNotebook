import SwiftUI

/// The open notebook: a grid page, a ribbon bookmark and index tabs on the right.
struct NotebookView: View {
    var onClose: () -> Void

    @State private var section = NotebookView.launchSection
    /// The day shown on the Today page and selected in the calendar.
    @State private var selectedDay = Date.now

    var body: some View {
        HStack(spacing: 0) {
            page
            IndexTabs(selection: $section, onClose: onClose)
        }
        .padding(.leading, 8)
        .padding(.vertical, 6)
    }

    private var page: some View {
        let shape = UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4,
                                           bottomTrailingRadius: 10, topTrailingRadius: 10)
        return ZStack(alignment: .topLeading) {
            GridPaper()

            // Each section scrolls its own paper (see `notebookPage()`), edge to edge
            sectionContent
                .id(section)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity))

            // Binding shadow on the left edge
            LinearGradient(colors: [.black.opacity(0.18), .clear],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: 22)
                .allowsHitTesting(false)

            PrintGrain()
        }
        .clipShape(shape)
        .background(PageStack())
        .shadow(color: .black.opacity(0.25), radius: 10, x: 2, y: 6)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch section {
        case .today:
            TodayView(day: $selectedDay, onDressUp: { withAnimation(.easeInOut(duration: 0.3)) { section = .closet } })
        case .calendar:
            CalendarView(selectedDay: $selectedDay, onOpenDay: openDay)
        case .todo:
            TodoView(onOpenDay: openDay)
        case .diary:
            DiaryView(day: $selectedDay)
        case .closet:
            ClosetView(day: selectedDay)
        case .stickers:
            StickerBookView(day: selectedDay, onOpenDay: openDay)
        }
    }

    /// Flip to a day's page, e.g. from the calendar.
    private func openDay(_ day: Date) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedDay = day
        withAnimation(.easeInOut(duration: 0.3)) { section = .today }
    }

    /// Launch with `--tab calendar` (etc.) to start on a specific section.
    private static var launchSection: NotebookSection {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "--tab"), index + 1 < arguments.count else { return .today }
        return NotebookSection(rawValue: arguments[index + 1]) ?? .today
    }
}

/// Coloured tabs sticking out of the right edge of the page.
private struct IndexTabs: View {
    @Binding var selection: NotebookSection
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ForEach(NotebookSection.allCases) { section in
                let selected = section == selection
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.easeInOut(duration: 0.3)) { selection = section }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: section.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(section.title)
                            .font(Theme.serif(11, .semibold))
                            .fixedSize()
                            .rotationEffect(.degrees(90))
                            .frame(width: 16, height: 58)
                    }
                    .foregroundStyle(Theme.ink.opacity(selected ? 0.9 : 0.6))
                    .frame(width: selected ? 34 : 28, height: 84)
                    .background(
                        UnevenRoundedRectangle(bottomTrailingRadius: 7, topTrailingRadius: 7)
                            .fill(section.tabColor.opacity(selected ? 1 : 0.75))
                            .shadow(color: .black.opacity(0.15), radius: 1.5, x: 1, y: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(section.title)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }

            Spacer()

            // Little red corner of the cover, tap to close the notebook
            Button(action: onClose) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.paper)
                    .frame(width: 30, height: 40)
                    .background(UnevenRoundedRectangle(bottomTrailingRadius: 7, topTrailingRadius: 7)
                        .fill(Theme.accent))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close notebook")
        }
        .frame(width: 36, alignment: .leading)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
}

#Preview {
    ZStack {
        DeskBackground()
        NotebookView(onClose: {})
    }
    .modelContainer(SampleData.container)
    .environment(CalendarStore())
}
