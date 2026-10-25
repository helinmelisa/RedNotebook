import PhotosUI
import SwiftData
import SwiftUI

/// A Clueless-style closet: flip through your clothes on a photo of yourself and save the outfit to the day.
struct ClosetView: View {
    let day: Date

    @Environment(\.modelContext) private var context
    @Query(sort: \ClothingItem.createdAt) private var wardrobe: [ClothingItem]
    @Query(sort: \BodyPhoto.createdAt, order: .reverse) private var bodyPhotos: [BodyPhoto]

    @State private var page: DayPage?
    @State private var category: ClothingCategory = .top
    @State private var selectedPiece: PersistentIdentifier?
    @State private var clothingPhoto: PhotosPickerItem?
    @State private var bodyPhotoItem: PhotosPickerItem?
    @State private var cuttingMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                closetWindow
                categoryChips
                wardrobeRow
                Text(selectedPiece == nil
                     ? "Tap a piece on you to move or resize it. It remembers the fit."
                     : "Drag to move, pinch to resize. Tap it again when it fits.")
                    .font(.system(size: 11, design: .serif).italic())
                    .foregroundStyle(Theme.ink.opacity(0.5))
            }
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        // While adjusting a piece, drags move it instead of scrolling
        .scrollDisabled(selectedPiece != nil)
        .task(id: day) {
            selectedPiece = nil
            page = DayPage.page(for: day, in: context)
        }
        .onChange(of: clothingPhoto) { _, item in
            guard let item else { return }
            Task { await addClothing(from: item) }
        }
        .onChange(of: bodyPhotoItem) { _, item in
            guard let item else { return }
            Task { await setBodyPhoto(from: item) }
        }
    }

    private var worn: [ClothingItem] { page?.wornItems ?? [] }
    private var inCategory: [ClothingItem] { wardrobe.filter { $0.category == category } }

    // MARK: - Header

    private var header: some View {
        PageTitle(eyebrow: Calendar.current.isDateInToday(day) ? "Today's outfit" : day.formatted(.dateTime.day().month(.wide)),
                  title: "Closet", color: NotebookSection.closet.tabColor) {
            Menu {
                PhotosPicker(selection: $bodyPhotoItem, matching: .images) {
                    Label(bodyPhotos.isEmpty ? "Add my body photo" : "Change my body photo", systemImage: "figure.stand")
                }
                if !worn.isEmpty {
                    Button("Take everything off", systemImage: "arrow.uturn.backward") {
                        withAnimation(.snappy) { page?.outfitItems = [] }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.ink.opacity(0.55))
            }
            .accessibilityLabel("Closet options")
        }
    }

    // MARK: - Closet window

    /// The outfit on a retro computer window, with arrows to flip through the current category.
    private var closetWindow: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                ForEach([Color(red: 1.0, green: 0.55, blue: 0.6), Color(red: 1.0, green: 0.82, blue: 0.4),
                         Color(red: 0.55, green: 0.85, blue: 0.6)], id: \.self) { color in
                    Circle().fill(color).frame(width: 7, height: 7)
                }
                Spacer()
                Text("closet.exe")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                Spacer()
                Text(category.emoji).font(.system(size: 11))
            }
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(Color(red: 0.62, green: 0.50, blue: 0.85))

            HStack(spacing: 0) {
                flipButton(-1, systemImage: "chevron.left")
                ZStack {
                    OutfitCanvas(bodyImage: bodyPhotos.first?.image, items: worn, selection: $selectedPiece)
                    if bodyPhotos.isEmpty {
                        PhotosPicker(selection: $bodyPhotoItem, matching: .images) {
                            Label("Add your full-length photo", systemImage: "camera")
                                .font(.system(size: 12, weight: .semibold, design: .serif))
                                .foregroundStyle(Theme.paper)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Theme.coverRed))
                        }
                    }
                    if let cuttingMessage {
                        VStack(spacing: 6) {
                            ProgressView()
                            Text(cuttingMessage).font(.system(size: 12, design: .serif))
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                    }
                }
                .frame(maxWidth: .infinity)
                flipButton(1, systemImage: "chevron.right")
            }
            .padding(.vertical, 8)
            .background(Color(red: 0.97, green: 0.95, blue: 1.0))
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(red: 0.62, green: 0.50, blue: 0.85), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
    }

    private func flipButton(_ direction: Int, systemImage: String) -> some View {
        Button { flip(direction) } label: {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.62, green: 0.50, blue: 0.85))
                .frame(width: 30, height: 60)
                .contentShape(Rectangle())
        }
        .disabled(inCategory.isEmpty)
        .opacity(inCategory.isEmpty ? 0.3 : 1)
        .accessibilityLabel(direction < 0 ? "Previous \(category.title)" : "Next \(category.title)")
    }

    // MARK: - Wardrobe

    private var categoryChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(ClothingCategory.allCases) { option in
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(.snappy) { category = option }
                    } label: {
                        Text("\(option.emoji) \(option.title)")
                            .font(.system(size: 12, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.ink.opacity(category == option ? 0.9 : 0.55))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(category == option
                                                       ? NotebookSection.stickers.tabColor.opacity(0.55)
                                                       : Theme.ink.opacity(0.05)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var wardrobeRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                PhotosPicker(selection: $clothingPhoto, matching: .images) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus").font(.system(size: 18, weight: .medium))
                        Text("Add").font(.system(size: 10, design: .serif))
                    }
                    .foregroundStyle(Theme.ink.opacity(0.5))
                    .frame(width: 64, height: 72)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Theme.ink.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                }
                .disabled(cuttingMessage != nil)
                .accessibilityLabel("Add \(category.title.lowercased()) from Photos")

                if inCategory.isEmpty {
                    Text("No \(category.title.lowercased()) yet. Add a photo of one, ideally laid flat on a plain background.")
                        .font(.system(size: 12, design: .serif).italic())
                        .foregroundStyle(Theme.ink.opacity(0.5))
                        .frame(width: 210, alignment: .leading)
                }

                ForEach(inCategory) { piece in
                    let isWorn = worn.contains { $0.persistentModelID == piece.persistentModelID }
                    Button { toggleWorn(piece) } label: {
                        Group {
                            if let image = piece.image {
                                Image(uiImage: image).resizable().scaledToFit().padding(6)
                            }
                        }
                        .frame(width: 64, height: 72)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.6)))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(isWorn ? Theme.coverRed : Theme.ink.opacity(0.1), lineWidth: isWorn ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isWorn ? "Take off" : "Wear")
                    .contextMenu {
                        Button("Reset fit", systemImage: "arrow.counterclockwise") { resetFit(piece) }
                        Button("Delete from closet", systemImage: "trash", role: .destructive) {
                            withAnimation(.snappy) { context.delete(piece) }
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Actions

    private func toggleWorn(_ piece: ClothingItem) {
        guard let page else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let isWorn = page.wornItems.contains { $0.persistentModelID == piece.persistentModelID }
        withAnimation(.snappy) {
            if isWorn {
                page.outfitItems?.removeAll { $0.persistentModelID == piece.persistentModelID }
            } else {
                wear(piece, on: page)
            }
        }
    }

    private func wear(_ piece: ClothingItem, on page: DayPage) {
        let replaced = piece.category.replaces
        page.outfitItems = (page.outfitItems ?? []).filter { !replaced.contains($0.category) } + [piece]
    }

    /// The ‹ › arrows: try on the previous/next piece in the category, passing through "nothing".
    private func flip(_ direction: Int) {
        guard let page, !inCategory.isEmpty else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        let options: [ClothingItem?] = [nil] + inCategory
        let current = options.firstIndex { option in
            guard let option else { return false }
            return page.wornItems.contains { $0.persistentModelID == option.persistentModelID }
        } ?? 0
        let next = (current + direction + options.count) % options.count
        selectedPiece = nil
        withAnimation(.snappy) {
            if let piece = options[next] {
                wear(piece, on: page)
            } else {
                page.outfitItems = (page.outfitItems ?? []).filter { $0.category != category }
            }
        }
    }

    private func resetFit(_ piece: ClothingItem) {
        let fit = piece.category.defaultFit
        withAnimation(.snappy) {
            piece.fitX = fit.x
            piece.fitTop = fit.top
            piece.fitWidth = fit.width
        }
    }

    private func addClothing(from item: PhotosPickerItem) async {
        cuttingMessage = "Cutting out…"
        defer { cuttingMessage = nil; clothingPhoto = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let png = await PhotoCutout.makeSticker(from: data) else { return }
        let piece = ClothingItem(imageData: png, category: category)
        context.insert(piece)
        if let page {
            withAnimation(.snappy) { wear(piece, on: page) }
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func setBodyPhoto(from item: PhotosPickerItem) async {
        cuttingMessage = "Cutting you out…"
        defer { cuttingMessage = nil; bodyPhotoItem = nil }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let png = await PhotoCutout.makeSticker(from: data) else { return }
        for old in bodyPhotos { context.delete(old) }
        context.insert(BodyPhoto(imageData: png))
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
