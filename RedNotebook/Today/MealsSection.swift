import SwiftUI

/// "What I ate": one handwritten line per meal.
struct MealsSection: View {
    @Bindable var page: DayPage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            MealLine(emoji: "🥐", title: "Breakfast", text: $page.breakfast)
            MealLine(emoji: "🥗", title: "Lunch", text: $page.lunch)
            MealLine(emoji: "🍝", title: "Dinner", text: $page.dinner)
            MealLine(emoji: "🍪", title: "Snacks", text: $page.snacks)
        }
    }
}

private struct MealLine: View {
    let emoji: String
    let title: String
    @Binding var text: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(emoji)
                .font(.system(size: 16))
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .tracking(1)
                .foregroundStyle(Theme.ink.opacity(0.5))
                .frame(width: 70, alignment: .leading)
            TextField("…", text: $text, axis: .vertical)
                .font(Theme.handwriting(size: 21))
                .foregroundStyle(Theme.ink)
                .accessibilityLabel(title)
        }
        .padding(.vertical, 2)
        .overlay(alignment: .bottom) {
            // Dotted writing line, like a printed journal
            Line()
                .stroke(Theme.ink.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [1, 3]))
                .frame(height: 1)
                .padding(.leading, 104)
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
