import SwiftUI

/// "Make it yours": pick the cover colour and the name pressed into it, with a live preview.
struct CoverCustomizer: View {
    @AppStorage(CoverColor.storageKey) private var colorRaw = CoverColor.red.rawValue
    @AppStorage(CoverFace.titleKey) private var title = CoverFace.defaultTitle
    @AppStorage("didPersonalizeCover") private var didPersonalize = false
    @AppStorage(SoundEffects.enabledKey) private var soundsOn = true
    @Environment(\.dismiss) private var dismiss

    private var color: CoverColor { CoverColor(rawValue: colorRaw) ?? .red }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    CoverFace(color: color, title: title)
                        .frame(width: 150, height: 150 * 148 / 105)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 3, y: 8)
                        .animation(.snappy, value: colorRaw)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(title: "Cover", color: color.accent)
                        HStack(spacing: 10) {
                            ForEach(CoverColor.allCases) { option in
                                Button {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    colorRaw = option.rawValue
                                } label: {
                                    Circle()
                                        .fill(LinearGradient(colors: [option.light, option.base, option.dark],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 34, height: 34)
                                        .overlay(Circle().stroke(Theme.paper, lineWidth: 2).padding(2))
                                        .overlay(Circle().stroke(option == color ? Theme.ink : .clear, lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(option.name)
                                .accessibilityAddTraits(option == color ? .isSelected : [])
                            }
                        }
                        Text(color.name)
                            .font(Theme.serif(13).italic())
                            .foregroundStyle(Theme.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(title: "Name on the cover", color: color.accent)
                        TextField("Your initials", text: $title)
                            .font(Theme.serif(22, .semibold))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.ink.opacity(0.05)))
                            .onChange(of: title) { _, new in
                                if new.count > 10 { title = String(new.prefix(10)) }
                            }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(title: "Sounds", color: color.accent)
                        Toggle("Paper and sticker sounds", isOn: $soundsOn)
                            .font(Theme.serif(16))
                            .tint(color.accent)
                    }
                }
                .padding(24)
            }
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle("Make it yours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        didPersonalize = true
                        dismiss()
                    }
                    .font(Theme.serif(16, .semibold))
                }
            }
        }
        .tint(color.accent)
        .presentationDetents([.large])
        .onDisappear { didPersonalize = true }
    }
}
