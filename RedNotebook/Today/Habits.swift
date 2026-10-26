import SwiftUI

/// Something to do (most) days, ticked off with a stamp on the day page.
struct Habit: Codable, Identifiable, Hashable {
    /// Stable, so renaming a habit keeps its history.
    var id: String = UUID().uuidString
    var emoji: String
    var name: String

    static let storageKey = "habits"

    static let defaults: [Habit] = [
        Habit(id: "water", emoji: "💧", name: "Water"),
        Habit(id: "sleep", emoji: "😴", name: "Sleep 8h"),
        Habit(id: "skincare", emoji: "🧴", name: "Skincare"),
        Habit(id: "portuguese", emoji: "🇵🇹", name: "Português"),
        Habit(id: "move", emoji: "🏃‍♀️", name: "Move"),
        Habit(id: "thesis", emoji: "📚", name: "Thesis"),
    ]

    /// The saved list, or the defaults until it's been edited. An empty saved list means no habits.
    static func list(from raw: String) -> [Habit] {
        guard !raw.isEmpty, let data = raw.data(using: .utf8),
              let habits = try? JSONDecoder().decode([Habit].self, from: data) else { return defaults }
        return habits
    }

    static func encode(_ habits: [Habit]) -> String {
        (try? JSONEncoder().encode(habits)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
}

/// A row of habit stamps under the date: tap one and it's inked in for the day.
struct HabitRow: View {
    @Bindable var page: DayPage

    @AppStorage(Habit.storageKey) private var habitsRaw = ""
    @State private var editing = false

    var body: some View {
        let habits = Habit.list(from: habitsRaw)
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: "Habits", color: NotebookSection.todo.tabColor) {
                if !habits.isEmpty {
                    Text("\(habits.filter { page.habitsDone.contains($0.id) }.count)/\(habits.count)")
                        .font(Theme.serif(11))
                        .foregroundStyle(Theme.inkTertiary)
                }
                Button { editing = true } label: {
                    Image(systemName: habits.isEmpty ? "plus" : "slider.horizontal.3")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.inkTertiary)
                        .frame(width: 28, height: 22)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit habits")
            }

            if habits.isEmpty {
                Text("Add a few habits to tick off each day.")
                    .font(Theme.serif(13).italic())
                    .foregroundStyle(Theme.inkTertiary)
            } else {
                HStack(spacing: 4) {
                    ForEach(habits) { habit in
                        HabitStamp(habit: habit, done: page.habitsDone.contains(habit.id)) { toggle(habit) }
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .sheet(isPresented: $editing) {
            HabitEditor(habitsRaw: $habitsRaw)
        }
    }

    private func toggle(_ habit: Habit) {
        if let index = page.habitsDone.firstIndex(of: habit.id) {
            page.habitsDone.remove(at: index)
        } else {
            page.habitsDone.append(habit.id)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            SoundEffects.shared.play(.tick)
        }
    }
}

/// One habit: a pencilled circle, inked in with the cover colour once done.
private struct HabitStamp: View {
    let habit: Habit
    let done: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(done ? Theme.accent.opacity(0.18) : .clear)
                    Circle()
                        .stroke(done ? Theme.accent : Theme.ink.opacity(0.25),
                                style: StrokeStyle(lineWidth: done ? 1.6 : 1, dash: done ? [] : [3, 2.5]))
                    Text(habit.emoji)
                        .font(.system(size: 17))
                        .grayscale(done ? 0 : 1)
                        .opacity(done ? 1 : 0.45)
                }
                .frame(width: 36, height: 36)
                .scaleEffect(done ? 1 : 0.94)
                .animation(.spring(duration: 0.3, bounce: 0.5), value: done)

                Text(habit.name)
                    .font(Theme.serif(9.5))
                    .foregroundStyle(done ? Theme.ink : Theme.inkTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(habit.name)
        .accessibilityAddTraits(done ? .isSelected : [])
    }
}

/// Add, rename, reorder and remove habits.
struct HabitEditor: View {
    @Binding var habitsRaw: String
    @Environment(\.dismiss) private var dismiss
    @State private var habits: [Habit] = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($habits) { $habit in
                        HStack(spacing: 12) {
                            TextField("🙂", text: $habit.emoji)
                                .font(.system(size: 22))
                                .frame(width: 36)
                                .multilineTextAlignment(.center)
                                .onChange(of: habit.emoji) { _, new in
                                    // One emoji only
                                    if new.count > 1 { habit.emoji = String(new.suffix(1)) }
                                }
                            TextField("Habit", text: $habit.name)
                                .font(Theme.serif(17))
                        }
                    }
                    .onDelete { habits.remove(atOffsets: $0) }
                    .onMove { habits.move(fromOffsets: $0, toOffset: $1) }

                    if habits.count < 8 {
                        Button {
                            habits.append(Habit(emoji: "⭐️", name: ""))
                        } label: {
                            Label("Add a habit", systemImage: "plus")
                                .font(Theme.serif(16))
                        }
                    }
                } footer: {
                    Text("Up to 8 habits. They show under the date on every page, and in Year in pixels.")
                        .font(Theme.serif(12))
                }

                Section {
                    Button("Ideas: water, sleep, skincare…") {
                        let ids = Set(habits.map(\.id))
                        habits += Habit.defaults.filter { !ids.contains($0.id) }.prefix(8 - habits.count)
                    }
                    .font(Theme.serif(15))
                    .disabled(habits.count >= 8)
                }
            }
            .scrollContentBackground(.hidden)
            .background(GridPaper().ignoresSafeArea())
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        habitsRaw = Habit.encode(habits.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty })
                        dismiss()
                    }
                    .font(Theme.serif(16, .semibold))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(Theme.serif(16))
                }
            }
        }
        .onAppear { habits = Habit.list(from: habitsRaw) }
    }
}
