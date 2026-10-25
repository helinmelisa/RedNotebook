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

            // Binding shadow on the left edge
            LinearGradient(colors: [.black.opacity(0.18), .clear],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: 22)
                .allowsHitTesting(false)

            sectionContent
                .padding(.leading, 28)
                .padding(.trailing, 44) // keep text clear of the ribbon
                .id(section)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity))

            Ribbon()
                .padding(.trailing, 22)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .clipShape(shape)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 2, y: 6)
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch section {
        case .today:
            TodayView(day: $selectedDay)
        case .calendar:
            CalendarView(selectedDay: $selectedDay, onOpenDay: openDay)
        case .todo:
            TodoView(onOpenDay: openDay)
        default:
            SectionPlaceholder(section: section)
                .padding(.top, 20)
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

/// Red satin ribbon bookmark hanging from the top of the page.
private struct Ribbon: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [Theme.ribbon.opacity(0.85), Theme.ribbon, Theme.ribbon.opacity(0.8)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: 9, height: 70)
            // Forked tail
            Path { p in
                p.move(to: .zero)
                p.addLine(to: CGPoint(x: 9, y: 0))
                p.addLine(to: CGPoint(x: 9, y: 8))
                p.addLine(to: CGPoint(x: 4.5, y: 4))
                p.addLine(to: CGPoint(x: 0, y: 8))
                p.closeSubpath()
            }
            .fill(Theme.ribbon)
            .frame(width: 9, height: 8)
        }
        .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1)
        .allowsHitTesting(false)
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
                            .font(.system(size: 11, weight: .semibold, design: .serif))
                            .fixedSize()
                            .rotationEffect(.degrees(90))
                            .frame(width: 16, height: 58)
                    }
                    .foregroundStyle(Theme.ink.opacity(selected ? 0.9 : 0.6))
                    .frame(width: selected ? 34 : 28, height: 96)
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
                        .fill(Theme.coverRed))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close notebook")
        }
        .frame(width: 36, alignment: .leading)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
}

/// Stand-in content until each section is built.
private struct SectionPlaceholder: View {
    let section: NotebookSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section == .today ? Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)) : section.title)
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(Theme.ink)
            Rectangle().fill(section.tabColor).frame(height: 2)
            Text("Coming soon")
                .font(.system(.body, design: .serif).italic())
                .foregroundStyle(Theme.ink.opacity(0.45))
        }
    }
}

#Preview {
    ZStack {
        Theme.desk.ignoresSafeArea()
        NotebookView(onClose: {})
    }
    .modelContainer(SampleData.container)
    .environment(CalendarStore())
}
