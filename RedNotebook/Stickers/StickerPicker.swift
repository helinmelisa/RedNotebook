import PhotosUI
import SwiftData
import SwiftUI

/// All stickers: your own from photos, the drawn pack and emoji. Tap one to pick it.
struct StickerPicker: View {
    /// The target is set when it was chosen in the tape or note maker; otherwise it's the page it was opened from.
    var onPick: (StickerChoice, StickerTarget?) -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: \PhotoSticker.createdAt, order: .reverse) private var photoStickers: [PhotoSticker]

    @State private var photoItem: PhotosPickerItem?
    @State private var isCutting = false
    @State private var makingWashi = false
    /// Tape made in the maker, stuck on once its sheet has closed.
    @State private var madeWashi: (StickerChoice, StickerTarget)?
    @State private var makingNote = false
    @State private var madeNote: (StickerChoice, StickerTarget)?

    var body: some View {
        ScrollViewReader { proxy in
        VStack(alignment: .leading, spacing: 22) {
            jumpBar(proxy)

            section("My stickers") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 12)], spacing: 12) {
                    addPolaroid
                    addWashi
                    addNote
                    addFromPhotos
                    ForEach(photoStickers) { sticker in
                        tile(.photo(sticker), size: 76)
                            .contextMenu {
                                Button("Delete sticker", systemImage: "trash", role: .destructive) {
                                    withAnimation(.snappy) { context.delete(sticker) }
                                }
                            }
                    }
                }
            }

            ForEach(DrawnSticker.Category.allCases, id: \.self) { category in
                section(category.rawValue) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 62), spacing: 2)], spacing: 6) {
                        ForEach(DrawnSticker.allCases.filter { $0.category == category }) { drawn in
                            tile(.drawn(drawn), size: 62)
                                .accessibilityLabel(drawn.name)
                        }
                    }
                }
                .id(category.rawValue)
            }

            section("Emoji") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 48), spacing: 6)], spacing: 6) {
                    ForEach(StickerEmoji.all, id: \.self) { emoji in
                        Button { pick(.emoji(emoji)) } label: {
                            Text(emoji).font(.system(size: 32)).frame(width: 48, height: 48)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await makeSticker(from: item) }
        }
        }

    }

    private var addFromPhotos: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            VStack(spacing: 4) {
                if isCutting {
                    ProgressView()
                    Text("Cutting…")
                } else {
                    Image(systemName: "photo.badge.plus").font(.system(size: 20))
                    Text("From Photos")
                }
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.ink.opacity(0.55))
            .frame(width: 76, height: 76)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .disabled(isCutting)
    }

    /// Photos of the day in a frame: polaroid, instax, film strip or photo-booth strip.
    private var addPolaroid: some View {
        PhotoFramePicker(onPick: { pick($0) }) {
            VStack(spacing: 4) {
                Image(systemName: "photo.on.rectangle").font(.system(size: 20))
                Text("Photo frame")
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.inkSecondary)
            .frame(width: 66, height: 76)
            .background(
                Rectangle().fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1.5)
            )
            .rotationEffect(.degrees(-3))
        }
        .disabled(isCutting)
        .accessibilityLabel("Add photos in a frame")
    }

    /// Make your own washi tape with any pattern, colour and writing.
    private var addWashi: some View {
        Button { makingWashi = true } label: {
            VStack(spacing: 6) {
                WashiPaper(color: WashiStyle.colors[0].color, pattern: .gingham)
                    .frame(width: 60, height: 18)
                    .rotationEffect(.degrees(-6))
                Text("Washi tape")
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.inkSecondary)
            .frame(width: 76, height: 76)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $makingWashi, onDismiss: {
            if let madeWashi { pick(madeWashi.0, to: madeWashi.1) }
            madeWashi = nil
        }) {
            WashiMaker { style, text, target in madeWashi = (.washi(style, text: text), target) }
        }
        .accessibilityLabel("Make washi tape")
    }

    /// Write a sticky note in any design and colour.
    private var addNote: some View {
        Button { makingNote = true } label: {
            VStack(spacing: 6) {
                Rectangle()
                    .fill(NoteStyle.colors[2].color)
                    .frame(width: 34, height: 32)
                    .shadow(color: .black.opacity(0.15), radius: 1, x: 1, y: 1)
                    .rotationEffect(.degrees(-5))
                Text("Sticky note")
            }
            .font(Theme.serif(11))
            .foregroundStyle(Theme.inkSecondary)
            .frame(width: 76, height: 76)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $makingNote, onDismiss: {
            if let madeNote { pick(madeNote.0, to: madeNote.1) }
            madeNote = nil
        }) {
            NoteMaker { style, text, target in madeNote = (.note(style, text: text), target) }
        }
        .accessibilityLabel("Write a sticky note")
    }

    /// Category chips that jump to a group, so the whole sticker book doesn't have to be scrolled through.
    private func jumpBar(_ proxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(DrawnSticker.Category.allCases, id: \.self) { category in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.easeInOut(duration: 0.35)) { proxy.scrollTo(category.rawValue, anchor: .top) }
                    } label: {
                        Text(category.rawValue)
                            .font(Theme.serif(12, .semibold))
                            .foregroundStyle(Theme.inkSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(NotebookSection.stickers.tabColor.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func tile(_ choice: StickerChoice, size: CGFloat) -> some View {
        Button { pick(choice) } label: {
            StickerContent(choice: choice)
                .scaleEffect(0.6)
                .frame(width: size, height: size * 0.85)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: title, color: NotebookSection.stickers.tabColor)
            content()
        }
    }

    private func pick(_ choice: StickerChoice, to target: StickerTarget? = nil) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onPick(choice, target)
    }

    private func makeSticker(from item: PhotosPickerItem) async {
        isCutting = true
        defer { isCutting = false; photoItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let png = await PhotoCutout.makeSticker(from: data) else { return }
        withAnimation(.snappy) { context.insert(PhotoSticker(imageData: png)) }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Sheet version of the picker, opened from a day page.
struct StickerDrawer: View {
    var onPick: (StickerChoice, StickerTarget?) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                StickerPicker { choice, target in
                    onPick(choice, target)
                    dismiss()
                }
                .padding(20)
            }
            .background(GridPaper().ignoresSafeArea())
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .tint(Theme.red)
        .presentationDetents([.medium, .large])
    }
}
