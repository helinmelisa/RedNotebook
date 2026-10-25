import SwiftUI

/// The Calendar tab: a Hobonichi-style monthly grid or a weekly agenda, with iPhone Calendar events.
struct CalendarView: View {
    @Binding var selectedDay: Date
    var onOpenDay: (Date) -> Void

    @Environment(CalendarStore.self) private var calendarStore
    @State private var mode: Mode = .month
    @State private var showingNewEvent = false

    enum Mode: String, CaseIterable {
        case month = "Month", week = "Week", year = "Year"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    modePicker
                    Spacer()
                    if calendarStore.hasAccess {
                        CalendarVisibilityMenu()
                        Button { showingNewEvent = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                        .accessibilityLabel("New event")
                    }
                }

                CalendarAccessBanner()

                switch mode {
                case .month:
                    MonthView(selectedDay: $selectedDay, onOpenDay: onOpenDay)
                case .week:
                    WeekView(selectedDay: $selectedDay, onOpenDay: onOpenDay)
                case .year:
                    YearView(selectedDay: $selectedDay, onOpenDay: onOpenDay)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showingNewEvent) {
            NewEventSheet(day: selectedDay)
        }
    }

    /// "Month · Week" in serif, with the active one underlined like a hand-drawn tab.
    private var modePicker: some View {
        HStack(spacing: 16) {
            ForEach(Mode.allCases, id: \.self) { option in
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(.snappy) { mode = option }
                } label: {
                    Text(option.rawValue.uppercased())
                        .font(Theme.serif(12, .semibold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.ink.opacity(mode == option ? 0.9 : 0.4))
                        .padding(.bottom, 4)
                        .overlay(alignment: .bottom) {
                            if mode == option {
                                Rectangle().fill(NotebookSection.calendar.tabColor).frame(height: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Asks for Calendar access, or explains how to turn it back on.
private struct CalendarAccessBanner: View {
    @Environment(CalendarStore.self) private var calendarStore
    @Environment(\.openURL) private var openURL

    var body: some View {
        if !calendarStore.hasAccess {
            VStack(alignment: .leading, spacing: 8) {
                Label("iPhone Calendar", systemImage: "calendar")
                    .font(Theme.serif(14, .semibold))
                Text(calendarStore.canAsk
                     ? "Connect your calendar to see your events here and add new ones."
                     : "Calendar access is off. Turn it on in Settings to see your events.")
                    .font(Theme.serif(13))
                    .foregroundStyle(Theme.ink.opacity(0.7))
                Button(calendarStore.canAsk ? "Connect" : "Open Settings") {
                    if calendarStore.canAsk {
                        Task { await calendarStore.requestAccess() }
                    } else if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .font(Theme.serif(13, .semibold))
                .foregroundStyle(Theme.accent)
            }
            .foregroundStyle(Theme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NotebookSection.calendar.tabColor.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
        }
    }
}

/// Lets you switch calendars on and off in the notebook, e.g. to hide another country's holidays.
private struct CalendarVisibilityMenu: View {
    @Environment(CalendarStore.self) private var calendarStore

    var body: some View {
        Menu {
            Section("Show in notebook") {
                ForEach(calendarStore.allCalendars, id: \.calendarIdentifier) { calendar in
                    Toggle(calendar.title, isOn: Binding(
                        get: { calendarStore.isVisible(calendar) },
                        set: { calendarStore.setVisible($0, calendar) }
                    ))
                }
            }
            Section {
                Text("🇵🇹 Portuguese holidays are built in")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.ink.opacity(0.55))
                .padding(.trailing, 10)
        }
        .accessibilityLabel("Choose calendars")
    }
}
