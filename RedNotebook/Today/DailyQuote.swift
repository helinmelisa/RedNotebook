import Foundation

/// A short quote at the bottom of every page, like the Hobonichi Techo.
enum DailyQuote {
    private static let quotes: [(text: String, author: String)] = [
        ("The days are long, but the years are short.", "Gretchen Rubin"),
        ("Write it on your heart that every day is the best day in the year.", "Ralph Waldo Emerson"),
        ("Little by little, one travels far.", "J.R.R. Tolkien"),
        ("How we spend our days is, of course, how we spend our lives.", "Annie Dillard"),
        ("Keep a little notebook. It will remember what you forget.", "Unknown"),
        ("Do small things with great love.", "Mother Teresa"),
        ("Not all those who wander are lost.", "J.R.R. Tolkien"),
        ("Today is the only day. Yesterday is gone.", "John Wooden"),
        ("Fill your paper with the breathings of your heart.", "William Wordsworth"),
        ("Nothing is worth more than this day.", "Goethe"),
        ("Happiness is not a goal; it is a by-product of a life well lived.", "Eleanor Roosevelt"),
        ("The secret of getting ahead is getting started.", "Mark Twain"),
        ("Every moment is a fresh beginning.", "T.S. Eliot"),
        ("Be curious, not judgmental.", "Walt Whitman"),
        ("Rest is not idleness.", "John Lubbock"),
        ("What you do today can improve all your tomorrows.", "Ralph Marston"),
        ("A journal is a place to meet yourself.", "Unknown"),
        ("Simplicity is the ultimate sophistication.", "Leonardo da Vinci"),
        ("One day or day one. You decide.", "Unknown"),
        ("Collect moments, not things.", "Unknown"),
        ("In the middle of every difficulty lies opportunity.", "Albert Einstein"),
    ]

    static func quote(for day: Date) -> (text: String, author: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: day) ?? 1
        return quotes[dayOfYear % quotes.count]
    }
}
