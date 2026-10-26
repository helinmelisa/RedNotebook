import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// "Make it yours": pick the cover colour and the name pressed into it, with a live preview.
struct CoverCustomizer: View {
    @AppStorage(CoverColor.storageKey) private var colorRaw = CoverColor.red.rawValue
    @AppStorage(CoverFace.titleKey) private var title = CoverFace.defaultTitle
    @AppStorage("didPersonalizeCover") private var didPersonalize = false
    @AppStorage(SoundEffects.enabledKey) private var soundsOn = true
    @AppStorage(AppLock.enabledKey) private var isLocked = false
    @AppStorage(NotebookBackup.lastBackupKey) private var lastBackup: Double = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var exported: ExportedFile?
    @State private var exportName = ""
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var pendingRestore: NotebookBackup?
    @State private var message: String?
    @State private var isWorking = false

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
                        HStack(spacing: 8) {
                            ForEach(CoverColor.allCases) { option in
                                Button {
                                    UISelectionFeedbackGenerator().selectionChanged()
                                    colorRaw = option.rawValue
                                } label: {
                                    Circle()
                                        .fill(LinearGradient(colors: [option.light, option.base, option.dark],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 32, height: 32)
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

                    VStack(alignment: .leading, spacing: 12) {
                        SectionLabel(title: "Privacy", color: color.accent)
                        Toggle("Lock with \(AppLock.methodName)", isOn: lockBinding)
                            .font(Theme.serif(16))
                            .tint(color.accent)
                        Text("The notebook asks for \(AppLock.methodName) when you open the cover, and closes itself when you leave the app.")
                            .font(Theme.serif(12))
                            .foregroundStyle(Theme.inkTertiary)
                    }

                    notebookFiles
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
                        updateAppIcon()
                        dismiss()
                    }
                    .font(Theme.serif(16, .semibold))
                }
            }
        }
        .tint(color.accent)
        .fileExporter(isPresented: $showingExporter, document: exported,
                      contentType: exported?.contentType ?? .json, defaultFilename: exportName) { result in
            if case .success = result, exported?.contentType == .json {
                lastBackup = Date.now.timeIntervalSince1970
                message = "Backed up. Keep the file somewhere safe, like iCloud Drive."
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            guard case .success(let url) = result else { return }
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            do {
                pendingRestore = try NotebookBackup.decode(Data(contentsOf: url))
            } catch {
                message = "That file isn't a helin's backup."
            }
        }
        .alert("Replace your notebook?", isPresented: Binding(get: { pendingRestore != nil }, set: { if !$0 { pendingRestore = nil } })) {
            Button("Replace everything", role: .destructive) {
                guard let backup = pendingRestore else { return }
                do {
                    try backup.restore(into: context)
                    message = "Restored \(backup.pages.count) pages from \(backup.createdAt.formatted(date: .abbreviated, time: .omitted))."
                } catch {
                    message = "Couldn't restore: \(error.localizedDescription)"
                }
                pendingRestore = nil
            }
            Button("Cancel", role: .cancel) { pendingRestore = nil }
        } message: {
            if let backup = pendingRestore {
                Text("Everything in the notebook now will be replaced by the backup from \(backup.createdAt.formatted(date: .long, time: .omitted)) (\(backup.pages.count) pages).")
            }
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("OK") { message = nil }
        }
        .presentationDetents([.large])
        .onDisappear { didPersonalize = true }
    }

    /// Back up, restore and print.
    private var notebookFiles: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: "Your notebook", color: color.accent)

            fileButton("Back up notebook", systemImage: "arrow.up.doc", detail: lastBackupText) {
                let backup = try NotebookBackup.make(from: context)
                exported = ExportedFile(data: try backup.encoded(), contentType: .json)
                exportName = NotebookBackup.fileName
            }

            fileButton("Restore from a backup", systemImage: "arrow.down.doc", detail: nil) {
                showingImporter = true
            }

            Menu {
                ForEach(0..<12, id: \.self) { offset in
                    let month = Calendar.current.date(byAdding: .month, value: -offset, to: .now)!
                    Button(month.formatted(.dateTime.month(.wide).year())) {
                        run {
                            guard let data = MonthPDF.make(month: month, from: context) else { return }
                            exported = ExportedFile(data: data, contentType: .pdf)
                            exportName = MonthPDF.fileName(for: month)
                        }
                    }
                }
            } label: {
                fileRow("Print a month as PDF", systemImage: "printer", detail: "A5 pages, ready to print or share")
            }
            .buttonStyle(.plain)

            if isWorking {
                ProgressView().frame(maxWidth: .infinity)
            }
        }
    }

    private var lastBackupText: String {
        guard lastBackup > 0 else { return "Never backed up. Your pages only live on this iPhone." }
        let date = Date(timeIntervalSince1970: lastBackup)
        return "Last backup " + date.formatted(.relative(presentation: .named))
    }

    private func fileButton(_ title: String, systemImage: String, detail: String?, action: @escaping () throws -> Void) -> some View {
        Button { run(action) } label: {
            fileRow(title, systemImage: systemImage, detail: detail)
        }
        .buttonStyle(.plain)
        .disabled(isWorking)
    }

    private func fileRow(_ title: String, systemImage: String, detail: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16))
                .foregroundStyle(color.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.serif(16)).foregroundStyle(Theme.ink)
                if let detail {
                    Text(detail).font(Theme.serif(12)).foregroundStyle(Theme.inkTertiary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    /// Runs a file action, then opens the exporter if it made a file.
    private func run(_ action: @escaping () throws -> Void) {
        isWorking = true
        exported = nil
        Task { @MainActor in
            // Let the spinner show before the (synchronous) work starts
            try? await Task.sleep(for: .milliseconds(50))
            do {
                try action()
                if exported != nil { showingExporter = true }
            } catch {
                message = "Something went wrong: \(error.localizedDescription)"
            }
            isWorking = false
        }
    }

    /// Turning the lock on checks Face ID works first, so you can't lock yourself out.
    private var lockBinding: Binding<Bool> {
        Binding {
            isLocked
        } set: { wanted in
            guard wanted else { isLocked = false; return }
            Task { @MainActor in
                isLocked = await AppLock.authenticate(reason: "Lock your notebook with \(AppLock.methodName)")
            }
        }
    }

    /// Repaints the Home Screen icon in the cover colour. iOS confirms the change with a short message.
    private func updateAppIcon() {
        let wanted = color.iconName
        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != wanted else { return }
        UIApplication.shared.setAlternateIconName(wanted)
    }
}
