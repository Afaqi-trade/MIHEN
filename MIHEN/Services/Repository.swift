import Foundation
import SwiftData

@MainActor final class Repository {
    let container: ModelContainer
    let context: ModelContext
    init(inMemory: Bool = false, storeURL: URL? = nil) throws {
        let schema = Schema(versionedSchema: MihenSchema.self)
        let config: ModelConfiguration
        if let storeURL { config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none) }
        else { config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, groupContainer: .none, cloudKitDatabase: .none) }
        container = try ModelContainer(for: schema, migrationPlan: MihenMigrationPlan.self, configurations: [config])
        context = ModelContext(container)
        context.autosaveEnabled = false
    }
    func load() throws -> BackupDocument {
        var result = BackupDocument()
        result.preferences = try context.fetch(FetchDescriptor<UserPreferences>()).map(\.record)
        result.domains = try context.fetch(FetchDescriptor<LifeDomain>()).map(\.record)
        result.subcategories = try context.fetch(FetchDescriptor<Subcategory>()).map(\.record)
        result.goals = try context.fetch(FetchDescriptor<Goal>()).map(\.record)
        result.milestones = try context.fetch(FetchDescriptor<GoalMilestone>()).map(\.record)
        result.goalProgress = try context.fetch(FetchDescriptor<GoalProgressEntry>()).map(\.record)
        result.tasks = try context.fetch(FetchDescriptor<PlannedTask>()).map(\.record)
        result.occurrences = try context.fetch(FetchDescriptor<TaskOccurrence>()).map(\.record)
        result.routines = try context.fetch(FetchDescriptor<Routine>()).map(\.record)
        result.routineItems = try context.fetch(FetchDescriptor<RoutineItem>()).map(\.record)
        result.projects = try context.fetch(FetchDescriptor<Project>()).map(\.record)
        result.khatms = try context.fetch(FetchDescriptor<QuranKhatm>()).map(\.record)
        result.readings = try context.fetch(FetchDescriptor<QuranReadingLog>()).map(\.record)
        result.memorization = try context.fetch(FetchDescriptor<MemorizationItem>()).map(\.record)
        result.memorizationReviews = try context.fetch(FetchDescriptor<MemorizationReview>()).map(\.record)
        result.dhikr = try context.fetch(FetchDescriptor<DhikrCounter>()).map(\.record)
        result.fasts = try context.fetch(FetchDescriptor<FastingPlan>()).map(\.record)
        result.events = try context.fetch(FetchDescriptor<CalendarEvent>()).map(\.record)
        result.journals = try context.fetch(FetchDescriptor<JournalEntry>()).map(\.record)
        result.activities = try context.fetch(FetchDescriptor<DomainActivity>()).map(\.record)
        result.notificationPreferences = try context.fetch(FetchDescriptor<NotificationPreference>()).map(\.record)
        return result
    }
    func save(_ data: BackupDocument) throws {
        try BackupCodec.validate(data)
        do {
            do {
                let rows = try context.fetch(FetchDescriptor<UserPreferences>())
                let wanted = Dictionary(uniqueKeysWithValues: data.preferences.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.preferences where !existing.contains(record.id) { context.insert(UserPreferences(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<LifeDomain>())
                let wanted = Dictionary(uniqueKeysWithValues: data.domains.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.domains where !existing.contains(record.id) { context.insert(LifeDomain(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<Subcategory>())
                let wanted = Dictionary(uniqueKeysWithValues: data.subcategories.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.subcategories where !existing.contains(record.id) { context.insert(Subcategory(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<Goal>())
                let wanted = Dictionary(uniqueKeysWithValues: data.goals.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.goals where !existing.contains(record.id) { context.insert(Goal(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<GoalMilestone>())
                let wanted = Dictionary(uniqueKeysWithValues: data.milestones.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.milestones where !existing.contains(record.id) { context.insert(GoalMilestone(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<GoalProgressEntry>())
                let wanted = Dictionary(uniqueKeysWithValues: data.goalProgress.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.goalProgress where !existing.contains(record.id) { context.insert(GoalProgressEntry(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<PlannedTask>())
                let wanted = Dictionary(uniqueKeysWithValues: data.tasks.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.tasks where !existing.contains(record.id) { context.insert(PlannedTask(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<TaskOccurrence>())
                let wanted = Dictionary(uniqueKeysWithValues: data.occurrences.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.occurrences where !existing.contains(record.id) { context.insert(TaskOccurrence(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<Routine>())
                let wanted = Dictionary(uniqueKeysWithValues: data.routines.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.routines where !existing.contains(record.id) { context.insert(Routine(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<RoutineItem>())
                let wanted = Dictionary(uniqueKeysWithValues: data.routineItems.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.routineItems where !existing.contains(record.id) { context.insert(RoutineItem(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<Project>())
                let wanted = Dictionary(uniqueKeysWithValues: data.projects.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.projects where !existing.contains(record.id) { context.insert(Project(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<QuranKhatm>())
                let wanted = Dictionary(uniqueKeysWithValues: data.khatms.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.khatms where !existing.contains(record.id) { context.insert(QuranKhatm(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<QuranReadingLog>())
                let wanted = Dictionary(uniqueKeysWithValues: data.readings.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.readings where !existing.contains(record.id) { context.insert(QuranReadingLog(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<MemorizationItem>())
                let wanted = Dictionary(uniqueKeysWithValues: data.memorization.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.memorization where !existing.contains(record.id) { context.insert(MemorizationItem(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<MemorizationReview>())
                let wanted = Dictionary(uniqueKeysWithValues: data.memorizationReviews.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.memorizationReviews where !existing.contains(record.id) { context.insert(MemorizationReview(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<DhikrCounter>())
                let wanted = Dictionary(uniqueKeysWithValues: data.dhikr.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.dhikr where !existing.contains(record.id) { context.insert(DhikrCounter(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<FastingPlan>())
                let wanted = Dictionary(uniqueKeysWithValues: data.fasts.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.fasts where !existing.contains(record.id) { context.insert(FastingPlan(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<CalendarEvent>())
                let wanted = Dictionary(uniqueKeysWithValues: data.events.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.events where !existing.contains(record.id) { context.insert(CalendarEvent(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<JournalEntry>())
                let wanted = Dictionary(uniqueKeysWithValues: data.journals.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.journals where !existing.contains(record.id) { context.insert(JournalEntry(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<DomainActivity>())
                let wanted = Dictionary(uniqueKeysWithValues: data.activities.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.activities where !existing.contains(record.id) { context.insert(DomainActivity(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<NotificationPreference>())
                let wanted = Dictionary(uniqueKeysWithValues: data.notificationPreferences.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.notificationPreferences where !existing.contains(record.id) { context.insert(NotificationPreference(record)) }
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
