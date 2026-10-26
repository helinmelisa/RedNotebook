import SwiftUI
import SwiftData

/// Every open task in the notebook, like a bullet journal future log:
/// overdue, today, upcoming and someday, plus what was done this week.
struct TodoView: View {
    var onOpenDay: (Date) -> Void

    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<BulletItem> { $0.kindRaw == "task" }, sort: \BulletItem.createdAt)
    private var tasks: [BulletItem]

    @State private var newText = ""
    @State private var addToSomeday = false
    @State private var showDone = false
    @FocusState private var isAdding: Bool

    var body: some View {
        let groups = TaskGroups(tasks: tasks)

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header(openCount: groups.openCount)
                addRow

                if groups.openCount == 0 {
                    Text("All clear ✨")
                        .font(Theme.serif(16).italic())
                        .foregroundStyle(Theme.ink.opacity(0.5))
                }

                if !groups.overdue.isEmpty {
                    TaskGroup(title: "Overdue", color: Theme.accent, tasks: groups.overdue,
                              showDates: true, onOpenDay: onOpenDay) {
                        Button("Move all to today", action: { moveAllToToday(groups.overdue) })
                    }
                }
                if !groups.today.isEmpty {
                    TaskGroup(title: "Today", color: NotebookSection.today.tabColor, tasks: groups.today,
                              showDates: false, onOpenDay: onOpenDay)
                }
                if !groups.upcoming.isEmpty {
                    TaskGroup(title: "Upcoming", color: NotebookSection.calendar.tabColor, tasks: groups.upcoming,
                              showDates: true, onOpenDay: onOpenDay)
                }
                if !groups.someday.isEmpty {
                    TaskGroup(title: "Someday", color: NotebookSection.stickers.tabColor, tasks: groups.someday,
                              showDates: false, onOpenDay: onOpenDay)
                }
                if !groups.done.isEmpty {
                    doneSection(groups.done)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
            .notebookPage()
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    private func header(openCount: Int) -> some View {
        PageTitle(eyebrow: openCount == 1 ? "1 open" : "\(openCount) open", title: "To-Do",
                  color: NotebookSection.todo.tabColor)
    }

    private var addRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("•")
                .font(.system(size: 18, weight: .bold))
                .opacity(0)
                .frame(width: 20)
                .overlay {
                    HandDrawnBox().stroke(Theme.inkTertiary, style: StrokeStyle(lineWidth: 1.2, dash: [2.5, 2]))
                        .frame(width: 15, height: 15).offset(y: 1)
                }
            TextField("New task…", text: $newText)
                .font(Theme.serif(16))
                .focused($isAdding)
                .submitLabel(.next)
                .onSubmit(add)
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                addToSomeday.toggle()
            } label: {
                Text(addToSomeday ? "Someday" : "Today")
                    .font(Theme.serif(12, .semibold))
                    .foregroundStyle(Theme.ink.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill((addToSomeday ? NotebookSection.stickers : NotebookSection.today)
                        .tabColor.opacity(0.45)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add to \(addToSomeday ? "someday" : "today")")
        }
    }

    private func doneSection(_ done: [BulletItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy) { showDone.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .rotationEffect(.degrees(showDone ? 90 : 0))
                    Text("DONE THIS WEEK · \(done.count)")
                        .font(Theme.serif(11, .semibold))
                        .tracking(1.5)
                }
                .foregroundStyle(Theme.ink.opacity(0.5))
            }
            .buttonStyle(.plain)

            if showDone {
                ForEach(done) { item in
                    TaskRow(item: item, showDate: true, onOpenDay: onOpenDay)
                }
            }
        }
    }

    private func add() {
        let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { isAdding = false; return }
        let item = BulletItem(text: text, kind: .task, order: 0)
        context.insert(item)
        withAnimation(.snappy) {
            item.schedule(on: addToSomeday ? nil : .now, in: context)
        }
        newText = ""
        isAdding = true
    }

    private func moveAllToToday(_ items: [BulletItem]) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.snappy) {
            for item in items { item.schedule(on: .now, in: context) }
        }
    }
}

/// Splits tasks into the sections of the To-Do tab.
private struct TaskGroups {
    var overdue: [BulletItem] = []
    var today: [BulletItem] = []
    var upcoming: [BulletItem] = []
    var someday: [BulletItem] = []
    var done: [BulletItem] = []

    init(tasks: [BulletItem]) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: startOfToday)!

        for task in tasks {
            let day = task.page?.day
            switch task.state {
            case .open:
                guard let day else { someday.append(task); continue }
                if day < startOfToday { overdue.append(task) }
                else if day == startOfToday { today.append(task) }
                else { upcoming.append(task) }
            case .done:
                if day.map({ $0 >= weekAgo }) ?? true { done.append(task) }
            case .migrated, .cancelled:
                break
            }
        }

        let byDay: (BulletItem, BulletItem) -> Bool = {
            ($0.page?.day ?? .distantFuture, $0.order) < ($1.page?.day ?? .distantFuture, $1.order)
        }
        overdue.sort(by: byDay)
        today.sort(by: byDay)
        upcoming.sort(by: byDay)
        done.sort { byDay($1, $0) }
    }

    var openCount: Int { overdue.count + today.count + upcoming.count + someday.count }
}

private struct TaskGroup<Action: View>: View {
    let title: String
    let color: Color
    let tasks: [BulletItem]
    let showDates: Bool
    var onOpenDay: (Date) -> Void
    @ViewBuilder var action: Action

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title, color: color, count: tasks.count) { action }
            ForEach(tasks) { item in
                TaskRow(item: item, showDate: showDates, onOpenDay: onOpenDay)
            }
        }
    }
}

extension TaskGroup where Action == EmptyView {
    init(title: String, color: Color, tasks: [BulletItem], showDates: Bool, onOpenDay: @escaping (Date) -> Void) {
        self.init(title: title, color: color, tasks: tasks, showDates: showDates, onOpenDay: onOpenDay) { EmptyView() }
    }
}

private struct TaskRow: View {
    @Bindable var item: BulletItem
    let showDate: Bool
    var onOpenDay: (Date) -> Void

    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Button(action: toggleDone) {
                BulletMark(item: item)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.state == .done ? "Mark not done" : "Mark done")

            TextField("", text: $item.text, axis: .vertical)
                .font(Theme.serif(16))
                .fixedSize(horizontal: false, vertical: true) // never clip a line that only just fits
                .strikethrough(item.state == .done, color: Theme.inkTertiary)
                .foregroundStyle(Theme.ink.opacity(item.isSettled ? 0.45 : 1))

            if showDate, let day = item.page?.day {
                Button { onOpenDay(day) } label: {
                    Text(dateLabel(day))
                        .font(Theme.serif(11))
                        .foregroundStyle(Theme.ink.opacity(0.5))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open \(day.formatted(date: .complete, time: .omitted))")
            }
        }
        .contextMenu {
            if item.state == .open {
                if !(item.page.map { Calendar.current.isDateInToday($0.day) } ?? false) {
                    Button("Move to today", systemImage: "sun.max") { move(to: .now) }
                }
                Button("Move to tomorrow", systemImage: "arrow.right") {
                    move(to: Calendar.current.date(byAdding: .day, value: 1, to: .now))
                }
                if item.page != nil {
                    Button("Move to someday", systemImage: "tray") { move(to: nil) }
                }
            }
            if let day = item.page?.day {
                Button("Open page", systemImage: "book") { onOpenDay(day) }
            }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation(.snappy) { context.delete(item) }
            }
        }
    }

    private func dateLabel(_ day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        if calendar.isDateInTomorrow(day) { return "Tomorrow" }
        return day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    private func toggleDone() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if item.state != .done { SoundEffects.shared.play(.tick) }
        withAnimation(.snappy) {
            item.state = item.state == .done ? .open : .done
        }
    }

    private func move(to day: Date?) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.snappy) { item.schedule(on: day, in: context) }
    }
}

#Preview {
    ZStack {
        GridPaper().ignoresSafeArea()
        TodoView(onOpenDay: { _ in })
            .padding(.horizontal, 24)
    }
    .modelContainer(SampleData.container)
}
