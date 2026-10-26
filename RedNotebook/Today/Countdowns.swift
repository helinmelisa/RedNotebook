import SwiftUI

/// Something to look forward to: "12 days until Antalya ✈️".
struct Countdown: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var emoji: String
    var title: String
    var date: Date

    static let storageKey = "countdowns"

    static func list(from raw: String) -> [Countdown] {
        guard let data = raw.data(using: .utf8),
              let countdowns = try? JSONDecoder().decode([Countdown].self, from: data) else { return [] }
        return countdowns.sorted { $0.date < $1.date }
    }

    static func encode(_ countdowns: [Countdown]) -> String {
        (try? JSONEncoder().encode(countdowns)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }

    /// Whole days from `day` to the countdown's date (0 on the day itself).
    func daysLeft(from day: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: day), to: calendar.startOfDay(for: date)).day ?? 0
    }
}

/// Tickets for the countdowns still ahead of this page's day.
struct CountdownStrip: View {
    let day: Date
    var onAdd: () -> Void
    var onEdit: (Countdown) -> Void

    @AppStorage(Countdown.storageKey) private var raw = ""

    var body: some View {
        let upcoming = Countdown.list(from: raw).filter { $0.daysLeft(from: day) >= 0 }
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                SectionLabel(title: "Counting down", color: NotebookSection.closet.tabColor) {
                    Button(action: onAdd) {
                        Image(systemName: "plus").font(.system(size: 12, weight: .semibold))
                    }
                    .accessibilityLabel("New countdown")
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(upcoming) { countdown in
                            Button { onEdit(countdown) } label: {
                                CountdownTicket(countdown: countdown, daysLeft: countdown.daysLeft(from: day))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 2)
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
        }
    }
}

/// A little admission ticket: big number on the stub, what it's for on the body.
struct CountdownTicket: View {
    let countdown: Countdown
    let daysLeft: Int

    private var paper: Color { Color(red: 0.99, green: 0.93, blue: 0.86) }
    private var ink: Color { Theme.accent }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                if daysLeft == 0 {
                    Text("TODAY")
                        .font(Theme.serif(13, .bold))
                        .tracking(1)
                } else {
                    Text("\(daysLeft)")
                        .font(Theme.serif(26, .bold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                    Text(daysLeft == 1 ? "DAY" : "DAYS")
                        .font(Theme.serif(8, .semibold))
                        .tracking(1.2)
                }
            }
            .foregroundStyle(ink)
            .frame(width: 58)

            // Perforation
            VStack(spacing: 3) {
                ForEach(0..<9, id: \.self) { _ in Circle().fill(ink.opacity(0.35)).frame(width: 2.5) }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(countdown.emoji).font(.system(size: 18))
                Text(countdown.title)
                    .font(Theme.handwriting(size: 20).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(countdown.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(Theme.serif(10))
                    .foregroundStyle(Theme.inkTertiary)
            }
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .frame(minWidth: 90, alignment: .leading)
        }
        .frame(height: 72)
        .background(TicketShape().fill(paper))
        .overlay(TicketShape().stroke(ink.opacity(0.35), lineWidth: 1))
        .compositingGroup()
        .shadow(color: .black.opacity(0.12), radius: 1.5, x: 0.5, y: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(daysLeft == 0 ? "\(countdown.title) is today" : "\(daysLeft) days until \(countdown.title)")
    }
}

/// A rectangle with half-circle notches where the stub tears off.
private struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        let notch: CGFloat = 6, x: CGFloat = 60
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: x - notch, y: rect.minY))
        path.addArc(center: CGPoint(x: x, y: rect.minY), radius: notch, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: x + notch, y: rect.maxY))
        path.addArc(center: CGPoint(x: x, y: rect.maxY), radius: notch, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Add or change a countdown.
struct CountdownEditor: View {
    /// nil adds a new one.
    let countdown: Countdown?

    @AppStorage(Countdown.storageKey) private var raw = ""
    @Environment(\.dismiss) private var dismiss
    @State private var emoji = "✈️"
    @State private var title = ""
    @State private var date = Calendar.current.date(byAdding: .day, value: 14, to: .now)!

    private static let suggestions = ["✈️", "🎂", "🎄", "🏖️", "🎓", "🎉", "💍", "🏔️", "🎫", "🧳", "🇹🇷", "🇵🇹"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Antalya, my birthday, thesis hand-in…", text: $title)
                        .font(Theme.serif(17))
                    DatePicker("Date", selection: $date, in: Calendar.current.startOfDay(for: .now)..., displayedComponents: .date)
                        .font(Theme.serif(16))
                }
                Section("Emoji") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(Self.suggestions, id: \.self) { option in
                            Button { emoji = option } label: {
                                Text(option)
                                    .font(.system(size: 26))
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(option == emoji ? Theme.accent.opacity(0.15) : .clear))
                                    .overlay(Circle().stroke(option == emoji ? Theme.accent : .clear, lineWidth: 1.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Section {
                    CountdownTicket(countdown: Countdown(emoji: emoji, title: title.isEmpty ? "Something lovely" : title, date: date),
                                    daysLeft: Countdown(emoji: emoji, title: title, date: date).daysLeft(from: .now))
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
                if countdown != nil {
                    Section {
                        Button("Delete countdown", role: .destructive) {
                            raw = Countdown.encode(Countdown.list(from: raw).filter { $0.id != countdown?.id })
                            dismiss()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle(countdown == nil ? "New countdown" : "Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.font(Theme.serif(16))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .font(Theme.serif(16, .semibold))
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            if let countdown {
                emoji = countdown.emoji
                title = countdown.title
                date = countdown.date
            }
        }
    }

    private func save() {
        var all = Countdown.list(from: raw).filter { $0.id != countdown?.id }
        all.append(Countdown(id: countdown?.id ?? UUID().uuidString, emoji: emoji,
                             title: title.trimmingCharacters(in: .whitespaces), date: Calendar.current.startOfDay(for: date)))
        raw = Countdown.encode(all)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}
