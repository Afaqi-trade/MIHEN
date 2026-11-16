import Foundation
import Observation
import SwiftData
import SwiftUI
import WidgetKit

@Observable @MainActor final class AppStore {
    var data: BackupDocument
    var errorMessage: String?
    var locked = false
    var lastProgressChange: (id: String, value: Double)?
    @ObservationIgnored private var notificationTask: Task<Void, Never>?
    let repository: Repository
    var engine: PlanningEngine {
        PlanningEngine(timeZone: TimeZone(identifier: preferences.timeZoneID) ?? .current, hijriOffset: preferences.hijriOffset, localeIdentifier: preferences.language)
    }
    var preferences: UserPreferencesRecord { data.preferences[0] }
    var locale: Locale { Locale(identifier: preferences.language) }
    var colorScheme: ColorScheme? { preferences.theme == "system" ? nil : preferences.theme == "dark" ? .dark : .light }
    init(repository: Repository) throws {
        self.repository = repository
        let loaded = try repository.load()
        if loaded.preferences.isEmpty && loaded.domains.isEmpty {
            data = .fresh()
            try repository.save(data)
        } else {
            try BackupCodec.validate(loaded)
            data = loaded
        }
        locked = preferences.lockEnabled
    }
    func t(_ key: String) -> String { Localization.text(key, language: preferences.language) }
    func taskTitle(_ title: String) -> String { Localization.recordTitle(title, language: preferences.language) }
    func title(_ domainID: String) -> String {
        guard let domain = data.domains.first(where: { $0.id == domainID }), let area = LifeArea(rawValue: domain.key) else { return domainID }
        return preferences.language == "tr" ? area.titleTR : area.titleEN
    }
    @discardableResult func change(_ operation: (inout BackupDocument) throws -> Void) -> Bool {
        var candidate = data
        do {
            try operation(&candidate)
            try candidate.reconcileSources(engine: engine)
            candidate.captureEstimates(engine:engine,on:Date())
            try repository.save(candidate)
            data = candidate
            publishWidget()
            refreshNotifications()
            return true
        } catch {
            errorMessage = (error as? PlanError).map { t($0.errorDescription ?? "validation.data") } ?? error.localizedDescription
            return false
        }
    }
    func updatePreferences(_ body: (inout UserPreferencesRecord) -> Void) {
        change { body(&$0.preferences[0]) }
    }
    func refresh(on date: Date = Date()) {
        let oldest = data.tasks.filter { !$0.archived }.map(\.start).min() ?? date
        // Backfill missed days (up to one year per foreground visit) using original task start dates.
        // Existing occurrences are immutable snapshots; explicit template editing also archives old future occurrences.
        let start = max(oldest, engine.addingDays(-366, to: date))
        let planner = engine
        change { planner.materialize(&$0, from: start, through: date) }
    }
    func occurrences(on date: Date) -> [TaskOccurrenceRecord] {
        data.occurrences.filter { $0.day == engine.key(date) }.sorted { $0.priority == $1.priority ? $0.title < $1.title : $0.priority > $1.priority }
    }
    func progress(_ id: String, value: Double) {
        let old = data.occurrences.first { $0.id == id }?.value
        if change({ document in
            guard !document.sourceLinks.contains(where: { $0.occurrenceID == id }) else { throw PlanError.invalid("source.disconnectFirst") }
            guard let i = document.occurrences.firstIndex(where: { $0.id == id }) else { throw PlanError.invalid("validation.missing") }
            try PlanningEngine.setProgress(value, occurrence: &document.occurrences[i])
        }), let old { lastProgressChange = (id, old) }
    }
    func undoProgress() {
        guard let last = lastProgressChange else { return }
        progress(last.id, value: last.value); lastProgressChange = nil
    }
    func addReading(khatmID: String, pages: Int) {
        change { document in
            guard let index = document.khatms.firstIndex(where: { $0.id == khatmID }), pages > 0 else { throw PlanError.invalid("validation.progress") }
            document.readings.append(.init(khatmID: khatmID, pages: pages))
            let total = document.readings.filter { $0.khatmID == khatmID }.reduce(0) { $0 + $1.pages }
            if total == document.khatms[index].totalPages { document.khatms[index].completedAt = Date() }
        }
    }
    func saveTask(_ record: PlannedTaskRecord, estimatedMinutes: Double? = nil, effective date: Date = Date()) {
        let planner = engine
        change { document in
            if let i = document.tasks.firstIndex(where: { $0.id == record.id }) {
                // Capture dates before this edit, so later backfill cannot rewrite the past.
                let start = document.tasks[i].start
                planner.materialize(&document, from: start, through: date)
                document.tasks[i] = record
                // Future unstarted occurrences may be regenerated; progress/history remains intact.
                document.occurrences.removeAll { $0.taskID == record.id && $0.day > planner.key(date) && $0.status == "planned" }
            } else { document.tasks.append(record) }
            planner.materialize(&document, from: date, through: date)
            try document.reconcileSources(engine:planner)
            try document.setTaskEstimate(record.id,minutes:estimatedMinutes,engine:planner,on:date)
        }
    }
    func publishWidget() {
        let summary = engine.summary(data, on: Date())
        let next = occurrences(on: Date()).first { $0.status == "planned" || $0.status == "partial" }
        let snapshot = WidgetSnapshot(day: engine.key(Date()), timeZoneID: preferences.timeZoneID, language: preferences.language, planned: summary.planned, completed: summary.completed, nextTitle: preferences.lockEnabled ? nil : next.map { taskTitle($0.title) }, locked: preferences.lockEnabled)
        do { try SharedWidgetStore.write(snapshot); WidgetCenter.shared.reloadAllTimelines() }
        catch { /* Widget is optional: an unconfigured App Group never prevents local persistence. */ }
    }
    func refreshNotifications() {
        let snapshot = data
        let previous = notificationTask
        previous?.cancel()
        notificationTask = Task {
            _ = await previous?.result
            do { try await ReminderService.reschedule(snapshot) }
            catch is CancellationError {}
            catch { errorMessage = error.localizedDescription }
        }
    }
}
