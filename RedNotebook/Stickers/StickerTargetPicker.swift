import SwiftUI

/// "Stick on: Today · Diary", at the bottom of the tape and note makers.
struct StickerTargetPicker: View {
    @Binding var target: StickerTarget
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: "Stick on", color: color)
            HStack(spacing: 8) {
                ForEach(StickerTarget.allCases, id: \.self) { option in
                    let selected = option == target
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        target = option
                    } label: {
                        Label(option == .today ? "Today's page" : "Diary page",
                              systemImage: option == .today ? "sun.max" : "book.closed")
                            .font(Theme.serif(14, selected ? .semibold : .regular))
                            .foregroundStyle(selected ? Theme.paper : Theme.inkSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(selected ? Theme.accent : .clear))
                            .overlay(Capsule().strokeBorder(selected ? .clear : Theme.hairline, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
