import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import WidgetKit

struct TransferDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .commaSeparatedText] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
struct ImportPreview: Identifiable {
    let id = UUID()
    var document: BackupDocument
    var replaces: Bool
    var errors: [String]
    var added: Int
    var prayer: PrayerSettings? = nil
    var restoresPrayer: Bool = false
}
struct SettingsScreen: View {
    @Environment(AppStore.self) private var store
    @AppStorage("backup.lastExport") private var lastExport = 0.0
    @State private var exportIsArchive = false
    @State private var exportSucceeded = false
    @State private var exporting = false
    @State private var importing = false
    @State private var exportDocument: TransferDocument?
    @State private var exportType: UTType = .json
    @State private var pendingImport: ImportPreview?
    @State private var reset = false
    @State private var notificationPrompt = false
    @State private var enablingLock = false
    var body: some View {
        Form {
            Section(store.t("profile")) {
                TextField(store.t("name"), text: preference(\.name))
                Picker(store.t("language"), selection: preference(\.language)) { Text("Türkçe").tag("tr"); Text("English").tag("en") }.accessibilityIdentifier("settings.language")
                Picker(store.t("theme"), selection: preference(\.theme)) { ForEach(["system", "light", "dark"], id: \.self) { Text(store.t($0)).tag($0) } }.accessibilityIdentifier("settings.theme")
                NavigationLink(destination: TimeZonePickerScreen(selection: preference(\.timeZoneID))) { LabeledContent(store.t("timezone"), value: store.preferences.timeZoneID) }
            }
            Section(store.t("connections")) {
                NavigationLink(destination: ScreenTimeScreen()) { Text(store.t("screen.title")) }.accessibilityIdentifier("settings.screentime")
                NavigationLink(destination: CustomRemindersScreen()) { Text(store.t("custom.reminders")) }
                NavigationLink(destination: HealthSummaryScreen()) { Text(store.t("health.connection")) }
            }
            Section(store.t("calendar.hijri")) {
                Toggle(store.t("hijri.show"), isOn: preference(\.showHijri))
                Stepper(store.t("hijri.offset") + ": \(store.preferences.hijriOffset)", value: preference(\.hijriOffset), in: -2...2)
                Text(store.t("hijri.explanation")).font(.footnote)
            }
            Section(store.t("rest.days")) {
                ForEach(1...7, id: \.self) { day in
                    Toggle(store.engine.calendar.weekdaySymbols[day - 1], isOn: Binding(get: { store.preferences.restWeekdays.contains(day) }, set: { value in store.updatePreferences { p in if value { p.restWeekdays.append(day) } else { p.restWeekdays.removeAll { $0 == day } } } }))
                }
            }
            Section(store.t("notifications")) {
                Toggle(store.t("notifications.enable"), isOn: Binding(get: { store.preferences.remindersEnabled }, set: { value in
                    if value { notificationPrompt = true }
                    else { store.updatePreferences { $0.remindersEnabled = false }; UNUserNotificationCenter.current().removeAllPendingNotificationRequests() }
                }))
                Stepper(store.t("notifications.hour") + ": \(store.preferences.reminderHour):00", value: preference(\.reminderHour), in: 0...23)
                Stepper(store.t("quiet.start") + ": \(store.preferences.quietStart):00", value: preference(\.quietStart), in: 0...23)
                Stepper(store.t("quiet.end") + ": \(store.preferences.quietEnd):00", value: preference(\.quietEnd), in: 0...23)
                ForEach(["evening", "weekly"], id: \.self) { kind in
                    Toggle(store.t("reminder.\(kind)"), isOn: Binding(get: { store.data.notificationPreferences.first { $0.kind == kind }?.enabled ?? false }, set: { value in
                        store.change { data in
                            if let i = data.notificationPreferences.firstIndex(where: { $0.kind == kind }) { data.notificationPreferences[i].enabled = value }
                            else { data.notificationPreferences.append(.init(kind: kind, enabled: value, hour: 20)) }
                        }
                    }))
                }
                Text(store.t("notifications.explanation")).font(.footnote)
            }
            Section(store.t("privacy")) {
                Toggle(store.t("lock"), isOn: Binding(get: { store.preferences.lockEnabled }, set: { value in
                    if value { enableLock() } else { store.updatePreferences { $0.lockEnabled = false } }
                })).disabled(enablingLock)
                NavigationLink(destination: PolicyScreen()) { Text(store.t("privacy.policy")) }
                Text(store.t("local.only")).font(.footnote)
                Text(store.t(SharedWidgetStore.url == nil ? "widget.unavailable" : "widget.available")).font(.footnote)
            }
            Section(store.t("data")) {
                if lastExport > 0 { Text(store.t("backup.lastExport")); Text(Date(timeIntervalSince1970: lastExport), format: .dateTime.day().month().year().hour().minute()) }
                else { Text(store.t("backup.none")) }
                Text(store.t("backup.location.notice")).font(.footnote).foregroundStyle(.secondary)
                if exportSucceeded { Text(store.t("backup.exported")).foregroundStyle(Color.mihenGreen) }
                Button(store.t("export.json")) { export(.json) }.buttonStyle(.borderedProminent)
                DisclosureGroup(store.t("backup.details")) {
                    Text(store.t("backup.scope")).font(.footnote)
                    Text(store.t("backup.explanation")).font(.footnote)
                }.accessibilityIdentifier("backup.details")
                Button(store.t("export.csv")) { export(.commaSeparatedText) }
                Button(store.t("export.planCSV")) { export(.commaSeparatedText, editablePlan: true) }
                Button(store.t("recovery.preview")) {
                    do { let archive = try RecoveryBackup.loadArchive(); let document = archive.document; pendingImport = .init(document: document, replaces: true, errors: [], added: document.tasks.count + document.goals.count + document.occurrences.count, prayer: archive.prayer, restoresPrayer: true) } catch { store.errorMessage = error.localizedDescription }
                }
                Button(store.t("import")) { importing = true }.accessibilityIdentifier("settings.import")
            }
            Section(store.t("plan.tools")) { NavigationLink(destination: StarterTemplatesScreen()) { Text(store.t("templates.choose")) }
            }
            Section(store.t("danger.zone")) { Button(store.t("data.delete"), role: .destructive) { reset = true } }
            Section(store.t("help")) {
                NavigationLink(destination: HelpScreen()) { Text(store.t("help.body")) }.accessibilityIdentifier("settings.help")
                Text("MİHEN 1.0.0 (1)").font(.caption)
                Text(store.t("cloud.unavailable")).font(.caption)
            }
        }.keyboardDone().navigationTitle(store.t("profile"))
            .fileExporter(isPresented: $exporting, document: exportDocument, contentType: exportType, defaultFilename: "MIHEN-\(store.engine.key(Date()))") { result in
                switch result {
                case .failure(let error): store.errorMessage = error.localizedDescription
                case .success: if exportIsArchive { lastExport = Date().timeIntervalSince1970; exportSucceeded = true }
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json, .commaSeparatedText], allowsMultipleSelection: false) { result in
                do { if let url = try result.get().first { try prepareImport(url) } } catch { store.errorMessage = error.localizedDescription }
            }
            .sheet(item: $pendingImport) { preview in
                NavigationStack {
                    List {
                        Text(store.t(preview.replaces ? "import.replaces" : "import.adds"))
                        Text(store.t(preview.restoresPrayer ? "backup.prayerIncluded" : "backup.legacy")).font(.footnote)
                        Text(store.t("records") + ": \(preview.added)")
                        Text(store.t("goals") + ": \(preview.document.goals.count)")
                        Text(store.t("tasks.habits") + ": \(preview.document.tasks.count)")
                        Text(store.t("history") + ": \(preview.document.occurrences.count)")
                        ForEach(preview.errors, id: \.self) { Text($0).foregroundStyle(.red) }
                        Button(store.t("import.confirm"), role: preview.replaces ? .destructive : nil) {
                            do {
                                try BackupArchive(document: preview.document, prayer: preview.prayer).validate()
                                let prayerBytes = try preview.prayer.map { try JSONEncoder().encode($0) }
                                try RecoveryBackup.preserve(store.data, prayer: PrayerSettingsStore.read())
                                if store.change({ $0 = preview.document }) {
                                    if preview.restoresPrayer { PrayerSettingsStore.restore(prayerBytes); WidgetCenter.shared.reloadAllTimelines() }
                                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                    if store.preferences.remindersEnabled { store.refreshNotifications() }
                                    store.lastProgressChange = nil
                                    pendingImport = nil
                                    store.locked = store.preferences.lockEnabled
                                }
                            } catch { store.errorMessage = error.localizedDescription }
                        }.disabled(!preview.errors.isEmpty)
                    }.keyboardDone().navigationTitle(store.t("import.preview"))
                        .toolbar { Button(store.t("cancel")) { pendingImport = nil } }
                }
            }
            .confirmationDialog(store.t("data.delete.confirm"), isPresented: $reset) {
                Button(store.t("data.delete"), role: .destructive) {
                    do { try ScreenTimeController.reset() } catch { store.errorMessage = error.localizedDescription; return }
                    if store.change({ $0 = .fresh() }) {
                        try? FileManager.default.removeItem(at: RecoveryBackup.url)
                        PrayerSettingsStore.clear()
                        WidgetCenter.shared.reloadAllTimelines()
                        lastExport = 0
                        exportSucceeded = false
                        store.lastProgressChange = nil
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                }
            }
            .confirmationDialog(store.t("notifications.permission"), isPresented: $notificationPrompt) {
                Button(store.t("continue")) {
                    Task {
                        do {
                            if try await ReminderService.enable() { store.updatePreferences { $0.remindersEnabled = true } }
                            else { store.errorMessage = store.t("notifications.denied") }
                        } catch { store.errorMessage = error.localizedDescription }
                    }
                }
            }
    }
    private func preference<T>(_ keyPath: WritableKeyPath<UserPreferencesRecord, T>) -> Binding<T> {
        Binding(get: { store.preferences[keyPath: keyPath] }, set: { value in store.updatePreferences { $0[keyPath: keyPath] = value } })
    }
    private func enableLock() {
        enablingLock = true
        Task {
            defer { enablingLock = false }
            do { if try await AppLock.authenticate(reason: store.t("lock.reason")) { store.updatePreferences { $0.lockEnabled = true } } }
            catch { store.errorMessage = error.localizedDescription }
        }
    }
    private func export(_ type: UTType, editablePlan: Bool = false) {
        do {
            var snapshot = store.data
            snapshot.exportedAt = Date()
            let bytes = type == .json ? try BackupArchive(document: snapshot, prayer: PrayerSettingsStore.read()).encoded() : Data((editablePlan ? PlanCSV.export(snapshot, engine: store.engine) : try BackupCodec.exportCSV(snapshot)).utf8)
            exportIsArchive = type == .json
            exportSucceeded = false
            exportDocument = TransferDocument(data: bytes)
            exportType = type
            exporting = true
        } catch { store.errorMessage = error.localizedDescription }
    }
    private func prepareImport(_ url: URL) throws {
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size <= BackupCodec.maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        let bytes = try Data(contentsOf: url, options: .mappedIfSafe)
        if url.pathExtension.lowercased() == "json" {
            let archive = try BackupArchive.decode(bytes)
            let document = archive.document
            let restoresPrayer = (try JSONSerialization.jsonObject(with: bytes) as? [String: Any])?["format"] != nil
            pendingImport = .init(document: document, replaces: true, errors: [], added: document.tasks.count + document.goals.count + document.occurrences.count, prayer: archive.prayer, restoresPrayer: restoresPrayer)
        } else {
            guard let text = String(data: bytes, encoding: .utf8) else { throw PlanError.invalid("validation.csv") }
            if try CSV.parse(text).first == PlanCSV.header {
                let preview = try PlanCSV.preview(text, into: store.data, engine: store.engine)
                var document = store.data
                document.goals += preview.goals
                document.tasks += preview.tasks
                if preview.errors.isEmpty { try BackupCodec.validate(document) }
                pendingImport = .init(document: document, replaces: false, errors: preview.errors + (preview.tasks.isEmpty && preview.goals.isEmpty ? [store.t("validation.emptyImport")] : []), added: preview.tasks.count + preview.goals.count)
            } else {
                let document = try BackupCodec.importCSV(text)
                pendingImport = .init(document: document, replaces: true, errors: [], added: document.tasks.count + document.goals.count + document.occurrences.count)
            }
        }
    }
}
struct PolicyScreen: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        ScrollView { Text(store.t("privacy.body")).padding().frame(maxWidth: .infinity, alignment: .leading) }.keyboardDone().navigationTitle(store.t("privacy.policy"))
    }
}
