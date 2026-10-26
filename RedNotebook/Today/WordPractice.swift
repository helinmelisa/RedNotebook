import SwiftUI

/// The words of the day so far, to practise as flashcards or a quick quiz.
enum WordDeck {
    static let knownKey = "knownPortugueseWords"

    /// Every word of the day from 1 January up to `day` (all of them once the year has gone round the list).
    static func words(upTo day: Date) -> [PortugueseWord] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: day) ?? 1
        return Array(PortugueseWord.all.prefix(min(dayOfYear, PortugueseWord.all.count)))
    }

    static func known(from raw: String) -> Set<String> {
        Set(raw.split(separator: "|").map(String.init))
    }

    static func encode(_ known: Set<String>) -> String {
        known.sorted().joined(separator: "|")
    }
}

/// "Practice": flashcards (tap to flip) or a four-choice quiz.
struct WordPractice: View {
    let day: Date

    @Environment(\.dismiss) private var dismiss
    @State private var mode: Mode = .cards

    enum Mode: String, CaseIterable {
        case cards = "Flashcards", quiz = "Quiz"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 18) {
                    ForEach(Mode.allCases, id: \.self) { option in
                        Button {
                            UISelectionFeedbackGenerator().selectionChanged()
                            withAnimation(.snappy) { mode = option }
                        } label: {
                            Text(option.rawValue.uppercased())
                                .font(Theme.serif(13, .semibold))
                                .tracking(1.5)
                                .foregroundStyle(mode == option ? Theme.ink : Theme.inkTertiary)
                                .padding(.bottom, 4)
                                .overlay(alignment: .bottom) {
                                    if mode == option {
                                        Capsule().fill(PortugueseHolidays.color).frame(height: 2)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }

                switch mode {
                case .cards: FlashcardDeck(words: WordDeck.words(upTo: day))
                case .quiz: WordQuiz(words: WordDeck.words(upTo: day))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle("Praticar 🇵🇹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(Theme.serif(16, .semibold))
                }
            }
        }
        .tint(PortugueseHolidays.color)
    }
}

// MARK: - Flashcards

private struct FlashcardDeck: View {
    let words: [PortugueseWord]

    @AppStorage(WordDeck.knownKey) private var knownRaw = ""
    @State private var queue: [PortugueseWord] = []
    @State private var flipped = false
    @State private var started = false

    private var known: Set<String> { WordDeck.known(from: knownRaw) }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("\(queue.count) to go")
                Spacer()
                Text("\(words.filter { known.contains($0.word) }.count) of \(words.count) known")
            }
            .font(Theme.serif(12))
            .foregroundStyle(Theme.inkTertiary)

            if let card = queue.first {
                Flashcard(word: card, flipped: flipped)
                    .id(card.word)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)))
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(duration: 0.45)) { flipped.toggle() }
                    }

                HStack(spacing: 12) {
                    answerButton("Again", systemImage: "arrow.counterclockwise", filled: false) {
                        queue.append(queue.removeFirst())
                    }
                    answerButton("I know it", systemImage: "checkmark", filled: true) {
                        var set = known
                        set.insert(queue.removeFirst().word)
                        knownRaw = WordDeck.encode(set)
                    }
                }
                Text(flipped ? " " : "Tap the card to see what it means")
                    .font(Theme.serif(12).italic())
                    .foregroundStyle(Theme.inkTertiary)
            } else {
                VStack(spacing: 12) {
                    Text("🎉").font(.system(size: 50))
                    Text("Muito bem!")
                        .font(Theme.serif(26, .semibold))
                    Text("You know all \(words.count) words so far.")
                        .font(Theme.serif(14))
                        .foregroundStyle(Theme.inkSecondary)
                    Button("Practise them all again") {
                        knownRaw = ""
                        deal(all: true)
                    }
                    .font(Theme.serif(15, .semibold))
                    .padding(.top, 8)
                }
                .padding(.top, 60)
            }
        }
        .onAppear {
            guard !started else { return }
            started = true
            deal(all: false)
        }
    }

    /// Words you don't know yet, newest first so today's word comes up early, then shuffled a little.
    private func deal(all: Bool) {
        let unknown = words.reversed().filter { all || !known.contains($0.word) }
        let recent = Array(unknown.prefix(5)), rest = unknown.dropFirst(5).shuffled()
        withAnimation { queue = recent + rest }
        flipped = false
    }

    private func answerButton(_ title: String, systemImage: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            flipped = false
            withAnimation(.snappy) { action() }
        } label: {
            Label(title, systemImage: systemImage)
                .font(Theme.serif(15, .semibold))
                .foregroundStyle(filled ? Theme.paper : PortugueseHolidays.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Capsule().fill(filled ? PortugueseHolidays.color : .clear)
                        .overlay(Capsule().stroke(PortugueseHolidays.color, lineWidth: 1.5))
                )
        }
        .buttonStyle(.plain)
    }
}

/// An index card: the word on the front, meaning and example on the back.
private struct Flashcard: View {
    let word: PortugueseWord
    let flipped: Bool

    var body: some View {
        ZStack {
            front.opacity(flipped ? 0 : 1)
            back.opacity(flipped ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .background(IndexCardBackground())
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PortugueseHolidays.color.opacity(0.35))
                .frame(width: 70, height: 18)
                .rotationEffect(.degrees(-4))
                .offset(y: -9)
        }
        .rotationEffect(.degrees(-1))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Flips the card")
    }

    private var front: some View {
        VStack(spacing: 14) {
            Text(word.word)
                .font(Theme.serif(38, .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
            speaker(word.word)
        }
        .padding(24)
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(word.word)
                .font(Theme.serif(20, .semibold))
                .foregroundStyle(PortugueseHolidays.color)
            Text(word.meaning)
                .font(Theme.serif(18).italic())
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline) {
                Text(word.sentence)
                    .font(Theme.handwriting(size: 24))
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 0)
                speaker(word.sentence)
            }
            Text(word.translation)
                .font(Theme.serif(13))
                .foregroundStyle(Theme.inkTertiary)
        }
        .padding(.horizontal, 22)
        .padding(.top, 44)
        .padding(.bottom, 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func speaker(_ text: String) -> some View {
        Button { PortugueseSpeaker.say(text) } label: {
            Image(systemName: "speaker.wave.2")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(PortugueseHolidays.color)
                .frame(width: 40, height: 34)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Hear it")
    }
}

// MARK: - Quiz

private struct WordQuiz: View {
    let words: [PortugueseWord]

    private static let length = 10

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var picked: Int?
    @State private var score = 0

    struct Question {
        let word: PortugueseWord
        let options: [String]
        let answer: Int
    }

    var body: some View {
        VStack(spacing: 18) {
            if index < questions.count {
                let question = questions[index]
                HStack {
                    Text("Question \(index + 1) of \(questions.count)")
                    Spacer()
                    Text("\(score) right")
                }
                .font(Theme.serif(12))
                .foregroundStyle(Theme.inkTertiary)

                VStack(spacing: 6) {
                    Text("What does this mean?")
                        .font(Theme.serif(13).italic())
                        .foregroundStyle(Theme.inkSecondary)
                    Text(question.word.word)
                        .font(Theme.serif(34, .semibold))
                        .foregroundStyle(Theme.ink)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 42)
                .padding(.bottom, 24)
                .background(IndexCardBackground())
                .onTapGesture { PortugueseSpeaker.say(question.word.word) }

                VStack(spacing: 10) {
                    ForEach(question.options.indices, id: \.self) { option in
                        optionButton(question, option)
                    }
                }

                if picked != nil {
                    Button(index + 1 < questions.count ? "Next" : "See my score") {
                        withAnimation(.snappy) {
                            picked = nil
                            index += 1
                        }
                    }
                    .font(Theme.serif(16, .semibold))
                    .foregroundStyle(Theme.paper)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(PortugueseHolidays.color))
                    .transition(.opacity)
                }
            } else if !questions.isEmpty {
                VStack(spacing: 10) {
                    Text(score >= 8 ? "🏆" : score >= 5 ? "🌟" : "🌱").font(.system(size: 50))
                    Text("\(score) / \(questions.count)")
                        .font(Theme.serif(40, .semibold))
                    Text(score >= 8 ? "Excelente!" : score >= 5 ? "Muito bem!" : "Continua! Keep going.")
                        .font(Theme.handwriting(size: 26))
                        .foregroundStyle(Theme.inkSecondary)
                    Button("Play again", action: newQuiz)
                        .font(Theme.serif(15, .semibold))
                        .padding(.top, 8)
                }
                .padding(.top, 50)
            } else {
                Text("Come back in a few days, when there are more words to mix up.")
                    .font(Theme.serif(14).italic())
                    .foregroundStyle(Theme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
            }
        }
        .onAppear { if questions.isEmpty { newQuiz() } }
    }

    private func optionButton(_ question: Question, _ option: Int) -> some View {
        let isAnswer = option == question.answer
        let state: (Color, Color) = switch picked {
        case nil: (Theme.ink.opacity(0.04), Theme.hairline)
        case _ where isAnswer: (Color(red: 0.62, green: 0.78, blue: 0.60).opacity(0.35), Color(red: 0.30, green: 0.55, blue: 0.30))
        case option: (Theme.accent.opacity(0.12), Theme.accent)
        default: (.clear, Theme.hairline)
        }
        return Button {
            guard picked == nil else { return }
            picked = option
            if isAnswer {
                score += 1
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        } label: {
            HStack {
                Text(question.options[option])
                    .font(Theme.serif(15))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                if picked != nil && isAnswer {
                    Image(systemName: "checkmark").foregroundStyle(state.1)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(RoundedRectangle(cornerRadius: 10).fill(state.0))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(state.1, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func newQuiz() {
        guard words.count >= 4 else { questions = []; return }
        questions = words.shuffled().prefix(Self.length).map { word in
            let wrong = words.filter { $0.word != word.word }.shuffled().prefix(3).map(\.meaning)
            let options = (wrong + [word.meaning]).shuffled()
            return Question(word: word, options: options, answer: options.firstIndex(of: word.meaning)!)
        }
        index = 0
        score = 0
        picked = nil
    }
}
