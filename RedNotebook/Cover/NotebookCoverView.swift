import SwiftUI

/// The closed red notebook. Tapping it slips the elastic band off and swings the cover open.
struct NotebookCoverView: View {
    var onOpen: () -> Void

    @State private var bandOff = false
    @State private var coverAngle: Double = 0
    @State private var isOpening = false

    private let year = Calendar.current.component(.year, from: .now)

    var body: some View {
        VStack(spacing: 28) {
            GeometryReader { geo in
                let size = bookSize(in: geo.size)

                ZStack {
                    // First page, revealed as the cover swings away
                    PageEdges()
                        .frame(width: size.width, height: size.height)
                    GridPaper()
                        .frame(width: size.width - 6, height: size.height - 6)
                        .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10))
                        .offset(x: -1, y: -1)

                    cover
                        .frame(width: size.width, height: size.height)
                        .rotation3DEffect(.degrees(coverAngle), axis: (x: 0, y: 1, z: 0),
                                          anchor: .leading, perspective: 0.45)
                        .opacity(coverAngle < -88 ? 0 : 1)
                }
                .frame(width: size.width, height: size.height)
                .shadow(color: .black.opacity(0.35), radius: 18, x: 6, y: 14)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .contentShape(Rectangle())
                .onTapGesture(perform: open)
            }

            Text("Tap to open")
                .font(.system(.footnote, design: .serif).italic())
                .foregroundStyle(Theme.ink.opacity(0.55))
                .opacity(isOpening ? 0 : 1)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Cover

    private var cover: some View {
        let shape = UnevenRoundedRectangle(topLeadingRadius: 3, bottomLeadingRadius: 3,
                                           bottomTrailingRadius: 12, topTrailingRadius: 12)
        return ZStack {
            shape.fill(
                LinearGradient(colors: [Theme.coverRedLight, Theme.coverRed, Theme.coverRedDark],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            LeatherTexture().clipShape(shape)

            // Stitching around the edge
            shape
                .inset(by: 10)
                .stroke(Theme.stitch, style: StrokeStyle(lineWidth: 1.2, dash: [5, 3.5]))

            spine
            title
            band
        }
        .clipShape(shape)
    }

    /// Darker strip on the left where the cover folds around the spine.
    private var spine: some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0.35), .black.opacity(0.05)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: 18)
            // Hinge groove
            Rectangle()
                .fill(.black.opacity(0.25))
                .frame(width: 1.5)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.white.opacity(0.10)).frame(width: 0.8).offset(x: 1)
                }
            Spacer()
        }
    }

    /// Debossed title, pressed into the leather.
    private var title: some View {
        VStack(spacing: 10) {
            Text("NOTEBOOK")
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .tracking(6)
            Rectangle().frame(width: 40, height: 1)
            Text(String(year))
                .font(.system(size: 15, weight: .medium, design: .serif))
                .tracking(4)
        }
        .foregroundStyle(Theme.coverRedDark.opacity(0.9))
        .shadow(color: .white.opacity(0.22), radius: 0, x: 0.8, y: 0.8)
        .shadow(color: .black.opacity(0.35), radius: 0, x: -0.6, y: -0.6)
        .offset(x: 6, y: -40)
    }

    /// Black elastic band near the right edge.
    private var band: some View {
        HStack {
            Spacer()
            LinearGradient(colors: [Theme.band.opacity(0.9), Color(white: 0.25), Theme.band],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: 13)
                .shadow(color: .black.opacity(0.5), radius: 2, x: -1, y: 0)
                .padding(.trailing, 26)
                .offset(x: bandOff ? 80 : 0)
                .opacity(bandOff ? 0 : 1)
        }
    }

    // MARK: - Actions

    private func open() {
        guard !isOpening else { return }
        isOpening = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        Task { @MainActor in
            withAnimation(.easeIn(duration: 0.25)) { bandOff = true }
            try? await Task.sleep(for: .milliseconds(280))

            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeIn(duration: 0.6)) { coverAngle = -90 }
            try? await Task.sleep(for: .milliseconds(620))

            withAnimation(.easeOut(duration: 0.3)) { onOpen() }
        }
    }

    /// A6-ish proportions (Hobonichi Original size), fitted to the available space.
    private func bookSize(in available: CGSize) -> CGSize {
        let ratio: CGFloat = 148.0 / 105.0
        let maxWidth = min(available.width - 48, 360)
        let width = min(maxWidth, available.height / ratio)
        return CGSize(width: width, height: width * ratio)
    }
}

/// Thin cream lines peeking out on the right and bottom, like a stack of pages.
private struct PageEdges: View {
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                    .fill(Theme.paper)
                    .overlay(
                        UnevenRoundedRectangle(bottomTrailingRadius: 10, topTrailingRadius: 10)
                            .stroke(.black.opacity(0.08), lineWidth: 0.5)
                    )
                    .offset(x: CGFloat(i) * 1.2, y: CGFloat(i) * 1.2)
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.desk.ignoresSafeArea()
        NotebookCoverView(onOpen: {})
    }
}
