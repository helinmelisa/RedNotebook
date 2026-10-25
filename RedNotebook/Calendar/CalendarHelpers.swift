import Foundation

extension Calendar {
    /// Days of the month containing `date`, padded with `nil` so the first day lands in the right weekday column.
    func monthGrid(for date: Date) -> [Date?] {
        guard let interval = dateInterval(of: .month, for: date),
              let count = range(of: .day, in: .month, for: date)?.count else { return [] }
        let leading = (component(.weekday, from: interval.start) - firstWeekday + 7) % 7
        let days = (0..<count).compactMap { self.date(byAdding: .day, value: $0, to: interval.start) }
        return Array(repeating: nil, count: leading) + days
    }

    /// The seven days of the week containing `date`, starting on the locale's first weekday.
    func week(containing date: Date) -> [Date] {
        guard let start = dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        return (0..<7).compactMap { self.date(byAdding: .day, value: $0, to: start) }
    }

    /// Very short weekday names (M, T, W…) in the order the locale starts its week.
    var orderedWeekdaySymbols: [String] {
        let symbols = veryShortStandaloneWeekdaySymbols
        let shift = firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}
