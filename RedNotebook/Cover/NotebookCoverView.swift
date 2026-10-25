import SwiftUI

/// The closed notebook. Tapping it slips the elastic band off and swings the cover open.
struct NotebookCoverView: View {
    var onOpen: () -> Void

    @AppStorage(CoverFace.titleKey) private var title = CoverFace.defaultTitle
    @AppStorage("didPersonalizeCover") private var didPersonalize = false
    @State private var bandOff = false
    @State private var coverAngle: Double = 0
    @State private var isOpening = false
    @State private var showingCustomizer = false

    var body: some View {
        VStack(spacing: 24) {
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

                    CoverFace(color: Theme.cover, title: title, bandOff: bandOff)
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

            VStack(spacing: 10) {
                Text("Tap to open")
                    .font(Theme.serif(13).italic())
                    .foregroundStyle(Theme.inkSecondary)
                Button {
                    showingCustomizer = true
                } label: {
                    Label("Customize cover", systemImage: "paintbrush")
                        .font(Theme.serif(13, .semibold))
                        .foregroundStyle(Theme.ink.opacity(0.7))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Theme.paper.opacity(0.7)))
                }
                .buttonStyle(.plain)
            }
            .opacity(isOpening ? 0 : 1)
        }
        .padding(.vertical, 40)
        .sheet(isPresented: $showingCustomizer) {
            CoverCustomizer()
        }
        .task {
            // First launch: make the notebook yours before opening it
            if !didPersonalize && !ProcessInfo.processInfo.arguments.contains("--open") {
                try? await Task.sleep(for: .milliseconds(600))
                showingCustomizer = true
            }
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
            SoundEffects.shared.play(.pageTurn)
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

/// The leather cover itself: colour, grain, stitching, spine, pressed-in title and elastic band.
struct CoverFace: View {
    let color: CoverColor
    let title: String
    var bandOff = false

    static let titleKey = "coverTitle"
    static let defaultTitle = "HME"

    private let year = Calendar.current.component(.year, from: .now)

    var body: some View {
        GeometryReader { geo in
            // Everything scales with the cover, so the small preview in the picker matches the real one
            let scale = geo.size.width / 330
            let shape = UnevenRoundedRectangle(topLeadingRadius: 3 * scale, bottomLeadingRadius: 3 * scale,
                                               bottomTrailingRadius: 12 * scale, topTrailingRadius: 12 * scale)
            ZStack {
                shape.fill(LinearGradient(colors: [color.light, color.base, color.dark],
                                          startPoint: .topLeading, endPoint: .bottomTrailing))
                LeatherTexture().clipShape(shape).opacity(color.isGlossy ? 0.25 : 1)
                if color.isGlossy {
                    // Shine: a soft glow at the top and a light band across, like lacquered card
                    LinearGradient(stops: [.init(color: .white.opacity(0.38), location: 0),
                                           .init(color: .white.opacity(0.08), location: 0.35),
                                           .init(color: .white.opacity(0.0), location: 0.5),
                                           .init(color: .white.opacity(0.16), location: 0.62),
                                           .init(color: .white.opacity(0.0), location: 0.72)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(shape)
                }

                shape
                    .inset(by: 10 * scale)
                    .stroke(Theme.stitch, style: StrokeStyle(lineWidth: 1.2 * scale, dash: [5 * scale, 3.5 * scale]))

                spine(scale)
                titleBlock(scale)
                band(scale)
            }
            .clipShape(shape)
        }
    }

    private func spine(_ scale: CGFloat) -> some View {
        HStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0.35), .black.opacity(0.05)], startPoint: .leading, endPoint: .trailing)
                .frame(width: 18 * scale)
            Rectangle()
                .fill(.black.opacity(0.25))
                .frame(width: 1.5 * scale)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(.white.opacity(0.10)).frame(width: 0.8 * scale).offset(x: scale)
                }
            Spacer()
        }
    }

    /// Debossed title, pressed into the leather.
    private func titleBlock(_ scale: CGFloat) -> some View {
        VStack(spacing: 10 * scale) {
            Text(title.isEmpty ? " " : title)
                .font(Theme.serif(34 * scale, .semibold))
                .tracking(10 * scale)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Rectangle().frame(width: 40 * scale, height: max(1 * scale, 0.5))
            Text(String(year))
                .font(Theme.serif(15 * scale, .medium))
                .tracking(4 * scale)
        }
        .foregroundStyle(color.dark.opacity(0.9))
        .shadow(color: .white.opacity(0.22), radius: 0, x: 0.8 * scale, y: 0.8 * scale)
        .shadow(color: .black.opacity(0.35), radius: 0, x: -0.6 * scale, y: -0.6 * scale)
        .padding(.horizontal, 44 * scale)
        .offset(x: 6 * scale, y: -40 * scale)
    }

    private func band(_ scale: CGFloat) -> some View {
        HStack {
            Spacer()
            LinearGradient(colors: [Theme.band.opacity(0.9), Color(white: 0.25), Theme.band],
                           startPoint: .leading, endPoint: .trailing)
                .frame(width: 13 * scale)
                .shadow(color: .black.opacity(0.5), radius: 2 * scale, x: -scale, y: 0)
                .padding(.trailing, 26 * scale)
                .offset(x: bandOff ? 80 : 0)
                .opacity(bandOff ? 0 : 1)
        }
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
        DeskBackground()
        NotebookCoverView(onOpen: {})
    }
}
