import SwiftUI
import SwiftData

/// Bullet journal lines for one day, plus a line to add new ones.
struct BulletList: View {
    @Bindable var page: DayPage
    var onMigrate: (BulletItem) -> Void

    @Environment(\.modelContext) private var context
    @State private var newText = ""
    @State private var newKind: BulletKind = .task
    @FocusState private var isAdding: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(page.sortedItems) { item in
                BulletRow(item: item,
                          onMigrate: { onMigrate(item) },
                          onDelete: { delete(item) })
            }
            addRow
        }
    }

    private var addRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Menu {
                Picker("Kind", selection: $newKind) {
                    ForEach(BulletKind.allCases) { kind in
                        Text("\(symbol(for: kind))  \(kind.name)").tag(kind)
                    }
                }
            } label: {
                Text(symbol(for: newKind))
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 18)
                    .foregroundStyle(Theme.ink.opacity(0.35))
            }
            .accessibilityLabel("Bullet kind: \(newKind.name)")

            TextField(newKind.placeholder, text: $newText)
                .font(.system(size: 16, design: .serif))
                .focused($isAdding)
                .submitLabel(.next)
                .onSubmit(add)
        }
    }

    private func symbol(for kind: BulletKind) -> String {
        switch kind {
        case .task: "•"
        case .event: "○"
        case .note: "–"
        }
    }

    private func add() {
        let text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { isAdding = false; return }
        let item = BulletItem(text: text, kind: newKind,
                              order: (page.sortedItems.last?.order ?? -1) + 1)
        withAnimation(.snappy) { item.page = page }
        newText = ""
        isAdding = true // keep the keyboard up for the next line
    }

    private func delete(_ item: BulletItem) {
        withAnimation(.snappy) { context.delete(item) }
    }
}

private struct BulletRow: View {
    @Bindable var item: BulletItem
    var onMigrate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Button(action: toggleDone) {
                Text(item.symbol)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 18)
                    .foregroundStyle(item.kind == .task && item.state == .done ? Theme.coverRed : Theme.ink)
                    .contentTransition(.numericText())
            }
            .buttonStyle(.plain)
            .disabled(item.kind != .task)
            .accessibilityLabel(item.state == .done ? "Mark not done" : "Mark done")

            TextField("", text: $item.text, axis: .vertical)
                .font(.system(size: 16, design: .serif))
                .strikethrough(item.state == .cancelled)
                .foregroundStyle(Theme.ink.opacity(item.isSettled ? 0.45 : 1))
        }
        .contextMenu {
            if item.kind == .task && item.state == .open {
                Button("Move to tomorrow", systemImage: "arrow.right", action: onMigrate)
                Button("Cancel task", systemImage: "line.diagonal") { item.state = .cancelled }
            }
            if item.state != .open {
                Button("Reopen", systemImage: "arrow.uturn.backward") { item.state = .open }
            }
            Picker("Change to", selection: Binding(get: { item.kind }, set: { item.kind = $0 })) {
                ForEach(BulletKind.allCases) { Text($0.name).tag($0) }
            }
            Divider()
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }

    private func toggleDone() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.snappy) {
            item.state = item.state == .done ? .open : .done
        }
    }
}
