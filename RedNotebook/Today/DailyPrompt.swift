import SwiftUI

/// A small question for each day, answered in a line or two.
enum DailyPrompt {
    private static let questions = [
        "What made you smile today?",
        "Something you learned today?",
        "What are you grateful for right now?",
        "Who did you enjoy talking to?",
        "The best thing you ate today?",
        "What would make tomorrow great?",
        "A small win from today?",
        "What song is stuck in your head?",
        "Where did you feel most at home today?",
        "What's something you're looking forward to?",
        "What did you notice on your walk?",
        "One thing you'd tell yourself this morning?",
        "What drained you, and what filled you up?",
        "A Portuguese word you heard or used today?",
        "What are you reading or watching?",
        "What colour was today?",
        "Something kind someone did?",
        "Something kind you did?",
        "What made you laugh?",
        "Which moment would you keep in a photo?",
        "What's on your mind tonight?",
        "What did you do just for yourself?",
        "A place you want to go back to?",
        "What surprised you today?",
        "What are you proud of this week?",
        "Something you miss from home?",
        "What would you do with a free afternoon?",
        "What did your body need today?",
        "Best smell of the day?",
        "A question you can't stop thinking about?",
        "What would you like to let go of?",
        "Three words for today?",
        "What made Porto beautiful today?",
        "A tiny thing that went right?",
        "What did you finally finish?",
        "Who would you like to see soon?",
        "What's a habit you're happy with?",
        "If today had a title, what would it be?",
        "The weather in your heart today?",
        "What did you wear and how did it feel?",
        "Something new you tried?",
        "What are you curious about lately?",
        "What gave you energy today?",
        "A compliment you'd give yourself?",
        "What do you want to remember about this year?",
        "Coffee, tea or something else today?",
        "The calmest moment of the day?",
        "What did you learn about yourself?",
        "What's one thing you'd change about today?",
        "A dream you had recently?",
        "What are you excited to wear next?",
        "What's a little luxury you enjoyed?",
        "Which friend would love today's story?",
        "A goal for this month?",
        "What's making you feel cosy lately?",
        "What did you say yes to?",
        "What did you say no to?",
        "Something you'd like to learn next?",
        "A memory from Türkiye that came back today?",
        "How do you want to feel tomorrow?",
    ]

    static func question(for day: Date) -> String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: day) ?? 1
        // Shift by year so the same date asks something different next year
        let year = calendar.component(.year, from: day)
        return questions[(dayOfYear + year * 7) % questions.count]
    }
}

/// The question of the day, with room for a short handwritten answer.
struct DailyPromptCard: View {
    @Bindable var page: DayPage

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Q.")
                    .font(Theme.serif(15, .semibold))
                    .foregroundStyle(Theme.accent)
                Text(DailyPrompt.question(for: page.day))
                    .font(Theme.serif(15).italic())
                    .foregroundStyle(Theme.ink.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(alignment: .top, spacing: 6) {
                Text("A.")
                    .font(Theme.serif(15, .semibold))
                    .foregroundStyle(Theme.inkTertiary)
                    .padding(.top, 5)
                TextField("Write a line…", text: $page.promptAnswer, axis: .vertical)
                    .lineLimit(1...)
                    .font(Theme.handwriting(size: 21))
                    .foregroundStyle(Theme.ink)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Theme.ink.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
        )
    }
}
