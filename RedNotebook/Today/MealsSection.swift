import SwiftData
import SwiftUI

/// "What I ate": a little food log with the time of each meal, in order through the day.
struct MealsSection: View {
    @Bindable var page: DayPage

    @Environment(\.modelContext) private var context
    @FocusState private var focused: PersistentIdentifier?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(page.sortedMeals) { meal in
                MealRow(meal: meal, focused: $focused) {
                    withAnimation(.snappy) { context.delete(meal) }
                }
            }

            Button(action: add) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                    Text("Add what I ate")
                }
                .font(Theme.text(14))
                .foregroundStyle(Theme.inkTertiary)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .onAppear(perform: moveOldMealsToEntries)
    }

    /// New entry at the current time (or the current time of day on another day's page).
    private func add() {
        let calendar = Calendar.current
        let now = calendar.dateComponents([.hour, .minute], from: .now)
        let time = calendar.date(bySettingHour: now.hour ?? 12, minute: now.minute ?? 0, second: 0, of: page.day) ?? page.day
        let meal = MealEntry(time: time)
        context.insert(meal)
        // Append through the page so its observers see the new entry right away
        withAnimation(.snappy) { page.meals = (page.meals ?? []) + [meal] }
        focused = meal.persistentModelID
    }

    /// Pages written before meals had times kept them in four fixed lines; turn those into timed entries once.
    private func moveOldMealsToEntries() {
        let old: [(String, Int, Int)] = [(page.breakfast, 8, 30), (page.lunch, 13, 0), (page.snacks, 16, 30), (page.dinner, 20, 0)]
        guard old.contains(where: { !$0.0.isEmpty }) else { return }
        for (text, hour, minute) in old where !text.isEmpty {
            let time = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: page.day) ?? page.day
            let meal = MealEntry(time: time, text: text)
            context.insert(meal)
            page.meals = (page.meals ?? []) + [meal]
        }
        page.breakfast = ""
        page.lunch = ""
        page.snacks = ""
        page.dinner = ""
    }
}

private struct MealRow: View {
    @Bindable var meal: MealEntry
    var focused: FocusState<PersistentIdentifier?>.Binding
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            DatePicker("Time", selection: $meal.time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .scaleEffect(0.85, anchor: .leading)
                .frame(width: 74, alignment: .leading)

            Text(meal.kind.emoji)
                .font(.system(size: 17))
                .accessibilityLabel(meal.kind.name)

            TextField(meal.kind.name + "…", text: $meal.text, axis: .vertical)
                .font(Theme.handwriting(size: 21))
                .foregroundStyle(Theme.ink)
                .focused(focused, equals: meal.persistentModelID)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 1)
        .overlay(alignment: .bottom) {
            // Dotted writing line, like a printed journal
            Line()
                .stroke(Theme.hairline, style: StrokeStyle(lineWidth: 1, dash: [1, 3]))
                .frame(height: 1)
                .padding(.leading, 108)
        }
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
