import SwiftUI

/// The title block at the top of every tab: a red eyebrow line, a big serif title and a coloured rule.
struct PageTitle<Trailing: View>: View {
    let eyebrow: String
    let title: String
    let color: Color
    var subtitle: String? = nil
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(eyebrow.uppercased())
                        .font(Theme.eyebrow)
                        .tracking(2)
                        .foregroundStyle(Theme.accent)
                    Text(title)
                        .font(Theme.display())
                        .foregroundStyle(Theme.ink)
                }
                Spacer(minLength: 8)
                trailing
            }
            if let subtitle {
                Text(subtitle)
                    .font(Theme.text(13))
                    .foregroundStyle(Theme.inkSecondary)
                    .padding(.top, 4)
            }
            Rule(color: color).padding(.top, 8)
        }
    }
}

extension PageTitle where Trailing == EmptyView {
    init(eyebrow: String, title: String, color: Color, subtitle: String? = nil) {
        self.init(eyebrow: eyebrow, title: title, color: color, subtitle: subtitle) { EmptyView() }
    }
}

/// A slightly uneven coloured line, like a rule drawn with a marker.
struct Rule: View {
    let color: Color

    var body: some View {
        Capsule()
            .fill(color)
            .frame(height: 2.5)
            .overlay(alignment: .trailing) {
                // Marker ink pools a little at the end of the stroke
                Capsule().fill(color).frame(width: 18, height: 3.5)
            }
    }
}

/// A small coloured dash and spaced capitals, labelling a part of the page.
struct SectionLabel<Trailing: View>: View {
    let title: String
    let color: Color
    var count: Int? = nil
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1.5).fill(color).frame(width: 14, height: 3)
            Text(count.map { "\(title.uppercased()) · \($0)" } ?? title.uppercased())
                .font(Theme.eyebrow)
                .tracking(1.5)
                .foregroundStyle(Theme.inkSecondary)
            Spacer(minLength: 0)
            trailing
                .font(Theme.serif(12, .semibold))
                .foregroundStyle(Theme.accent)
        }
    }
}

extension SectionLabel where Trailing == EmptyView {
    init(title: String, color: Color, count: Int? = nil) {
        self.init(title: title, color: color, count: count) { EmptyView() }
    }
}

/// Woven linen, the desk the notebook lies on.
struct DeskBackground: View {
    /// Leaves, snow or petals drifting across it (only around the closed notebook, so they don't distract from writing).
    var showsSeason = false

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.desk))
            var rng = SeededRandom(seed: 7)

            // Warp and weft threads with slight variation in strength
            for y in stride(from: 0.0, to: size.height, by: 2.5) {
                let alpha = Double.random(in: 0.02...0.07, using: &rng)
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 0.8)),
                             with: .color(.black.opacity(alpha)))
            }
            for x in stride(from: 0.0, to: size.width, by: 2.5) {
                let alpha = Double.random(in: 0.02...0.06, using: &rng)
                context.fill(Path(CGRect(x: x, y: 0, width: 0.8, height: size.height)),
                             with: .color(.white.opacity(alpha)))
            }
            // A few slubs, the thicker bits real linen has
            for _ in 0..<Int(size.width * size.height / 900) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let length = Double.random(in: 4...14, using: &rng)
                context.fill(Path(CGRect(x: x, y: y, width: length, height: 1.2)),
                             with: .color(.black.opacity(0.05)))
            }
        }
        .overlay {
            if showsSeason {
                SeasonalDesk().transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// The edges of the pages underneath, showing the notebook has thickness.
struct PageStack: View {
    var body: some View {
        ZStack {
            ForEach((1...3).reversed(), id: \.self) { i in
                UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4,
                                       bottomTrailingRadius: 10, topTrailingRadius: 10)
                    .fill(Theme.paperEdge)
                    .overlay(
                        UnevenRoundedRectangle(topLeadingRadius: 4, bottomLeadingRadius: 4,
                                               bottomTrailingRadius: 10, topTrailingRadius: 10)
                            .stroke(.black.opacity(0.08), lineWidth: 0.5)
                    )
                    .offset(x: CGFloat(i) * 1.5, y: CGFloat(i) * 1.5)
            }
        }
    }
}

/// Fine grain laid over everything on the page (multiply), so ink and stickers read as printed on paper.
struct PrintGrain: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 5)
            for _ in 0..<Int(size.width * size.height / 55) {
                let x = Double.random(in: 0...size.width, using: &rng)
                let y = Double.random(in: 0...size.height, using: &rng)
                let r = Double.random(in: 0.3...0.9, using: &rng)
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                             with: .color(Color(red: 0.45, green: 0.35, blue: 0.25).opacity(Double.random(in: 0.04...0.11, using: &rng))))
            }
        }
        .blendMode(.multiply)
        .drawingGroup()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Lays views out in rows, wrapping to the next line when one is full (like words in a paragraph).
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = rows(for: subviews, width: proposal.width ?? .infinity)
        var height: CGFloat = 0
        var width: CGFloat = 0
        for row in rows {
            let sizes = row.map { $0.sizeThatFits(.unspecified) }
            height += sizes.map(\.height).max() ?? 0
            let rowWidth: CGFloat = sizes.map(\.width).reduce(0, +) + spacing * CGFloat(row.count - 1)
            width = max(width, rowWidth)
        }
        height += spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(for: subviews, width: bounds.width) {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func rows(for subviews: Subviews, width: CGFloat) -> [[LayoutSubviews.Element]] {
        var rows: [[LayoutSubviews.Element]] = [[]]
        var x: CGFloat = 0
        for subview in subviews {
            let w = subview.sizeThatFits(.unspecified).width
            if x > 0 && x + w > width {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(subview)
            x += w + spacing
        }
        return rows
    }
}
