import SwiftUI

struct Holiday: Hashable {
    let date: Date
    let name: String
    /// Not a national public holiday: municipal (São João in Porto) or customary (Carnaval).
    let isOptional: Bool
}

/// Portuguese public holidays, built in so they don't depend on the phone's holiday calendar.
enum PortugueseHolidays {
    static let color = Color(red: 0.0, green: 0.45, blue: 0.25)

    static func holiday(on day: Date) -> Holiday? {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: day)
        return holidays(in: year).first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    static func holidays(in year: Int) -> [Holiday] {
        if let cached = cache[year] { return cached }

        let calendar = Calendar.current
        func date(_ month: Int, _ day: Int) -> Date {
            calendar.date(from: DateComponents(year: year, month: month, day: day))!
        }
        let easter = easterSunday(year: year)
        func fromEaster(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: easter)!
        }

        let list = [
            Holiday(date: date(1, 1), name: "Ano Novo", isOptional: false),
            Holiday(date: fromEaster(-47), name: "Carnaval", isOptional: true),
            Holiday(date: fromEaster(-2), name: "Sexta-feira Santa", isOptional: false),
            Holiday(date: easter, name: "Páscoa", isOptional: false),
            Holiday(date: date(4, 25), name: "Dia da Liberdade", isOptional: false),
            Holiday(date: date(5, 1), name: "Dia do Trabalhador", isOptional: false),
            Holiday(date: fromEaster(60), name: "Corpo de Deus", isOptional: false),
            Holiday(date: date(6, 10), name: "Dia de Portugal", isOptional: false),
            Holiday(date: date(6, 24), name: "São João (Porto)", isOptional: true),
            Holiday(date: date(8, 15), name: "Assunção de Nossa Senhora", isOptional: false),
            Holiday(date: date(10, 5), name: "Implantação da República", isOptional: false),
            Holiday(date: date(11, 1), name: "Dia de Todos os Santos", isOptional: false),
            Holiday(date: date(12, 1), name: "Restauração da Independência", isOptional: false),
            Holiday(date: date(12, 8), name: "Imaculada Conceição", isOptional: false),
            Holiday(date: date(12, 25), name: "Natal", isOptional: false),
        ]
        cache[year] = list
        return list
    }

    private static var cache: [Int: [Holiday]] = [:]

    /// Gregorian Easter (anonymous algorithm / Meeus–Jones–Butcher).
    static func easterSunday(year: Int) -> Date {
        let a = year % 19
        let b = year / 100, c = year % 100
        let d = b / 4, e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4, k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = (h + l - 7 * m + 114) % 31 + 1
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }
}

/// A holiday shown in the agenda, week and day pages.
struct HolidayLine: View {
    let holiday: Holiday

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            RoundedRectangle(cornerRadius: 1)
                .fill(PortugueseHolidays.color.opacity(holiday.isOptional ? 0.5 : 1))
                .frame(width: 3, height: 14)
            Text("🇵🇹")
                .font(.system(size: 12))
                .frame(width: 56, alignment: .leading)
            Text(holiday.name)
                .font(.system(size: 14, design: .serif).italic())
                .foregroundStyle(PortugueseHolidays.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Holiday: \(holiday.name)")
    }
}
