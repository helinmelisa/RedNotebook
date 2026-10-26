import SwiftUI

/// "Palavra do dia": an index card at the bottom of each day's page.
struct PortugueseWordCard: View {
    let day: Date

    @State private var practising = false

    var body: some View {
        let entry = PortugueseWord.of(day)

        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("PALAVRA DO DIA · 🇵🇹")
                    .font(Theme.eyebrow)
                    .tracking(1.5)
                    .foregroundStyle(PortugueseHolidays.color)
                Spacer()
                Button {
                    PortugueseSpeaker.say("\(entry.word). \(entry.sentence)")
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(PortugueseHolidays.color)
                        .frame(width: 32, height: 26)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hear it in Portuguese")
            }

            Text(entry.word)
                .font(Theme.serif(24, .semibold))
                .foregroundStyle(Theme.ink)
            Text(entry.meaning)
                .font(Theme.serif(13).italic())
                .foregroundStyle(Theme.inkSecondary)

            Rectangle().fill(Theme.hairline).frame(height: 0.5).padding(.vertical, 2)

            Text(entry.sentence)
                .font(Theme.handwriting(size: 21))
                .foregroundStyle(Theme.ink)
            Text(entry.translation)
                .font(Theme.serif(12))
                .foregroundStyle(Theme.inkTertiary)

            Button { practising = true } label: {
                Label("Practise \(WordDeck.words(upTo: day).count) words", systemImage: "rectangle.on.rectangle.angled")
                    .font(Theme.serif(13, .semibold))
                    .foregroundStyle(PortugueseHolidays.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().stroke(PortugueseHolidays.color.opacity(0.5), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(IndexCardBackground())
        // Held on with a strip of washi tape
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PortugueseHolidays.color.opacity(0.35))
                .frame(width: 64, height: 16)
                .rotationEffect(.degrees(-4))
                .offset(y: -8)
        }
        .rotationEffect(.degrees(-0.6))
        .sheet(isPresented: $practising) {
            WordPractice(day: day)
        }
    }
}
