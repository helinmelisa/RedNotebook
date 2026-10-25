import EventKit
import SwiftUI

/// Creates a new event in the iPhone Calendar.
struct NewEventSheet: View {
    let day: Date

    @Environment(CalendarStore.self) private var calendarStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var isAllDay = false
    @State private var start: Date
    @State private var end: Date
    @State private var calendarID: String?
    @State private var errorMessage: String?

    init(day: Date) {
        self.day = day
        // Default to the next full hour on the chosen day
        let calendar = Calendar.current
        let hour = calendar.isDateInToday(day) ? calendar.component(.hour, from: .now) + 1 : 9
        let start = calendar.date(bySettingHour: min(hour, 23), minute: 0, second: 0, of: day) ?? day
        _start = State(initialValue: start)
        _end = State(initialValue: start.addingTimeInterval(3600))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                    .font(.system(size: 17, design: .serif))

                Section {
                    Toggle("All day", isOn: $isAllDay)
                    DatePicker("Starts", selection: $start,
                               displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                    DatePicker("Ends", selection: $end, in: start...,
                               displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute])
                }

                Section {
                    Picker("Calendar", selection: $calendarID) {
                        ForEach(calendarStore.writableCalendars, id: \.calendarIdentifier) { calendar in
                            Label {
                                Text(calendar.title)
                            } icon: {
                                Image(systemName: "circle.fill").foregroundStyle(Color(cgColor: calendar.cgColor))
                            }
                            .tag(Optional(calendar.calendarIdentifier))
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { calendarID = calendarID ?? calendarStore.defaultCalendar?.calendarIdentifier }
            .onChange(of: start) { oldStart, newStart in
                // Keep the event's length when the start moves
                end = newStart.addingTimeInterval(end.timeIntervalSince(oldStart))
            }
        }
        .tint(Theme.coverRed)
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let calendar = calendarStore.writableCalendars.first { $0.calendarIdentifier == calendarID }
        do {
            try calendarStore.addEvent(title: title.trimmingCharacters(in: .whitespaces),
                                       start: start, end: end, isAllDay: isAllDay, calendar: calendar)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
