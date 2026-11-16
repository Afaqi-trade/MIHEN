import Foundation
import SwiftData

@MainActor final class Repository {
    let container: ModelContainer
    let context: ModelContext
    init(inMemory: Bool = false, storeURL: URL? = nil) throws {
        if !inMemory {
            let directory = storeURL?.deletingLastPathComponent() ?? URL.applicationSupportDirectory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
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
        result.sourceLinks = try context.fetch(FetchDescriptor<SourceLink>()).map(\.record)
        result.capacities = try context.fetch(FetchDescriptor<PlanningCapacity>()).map(\.record)
        result.taskEstimates = try context.fetch(FetchDescriptor<TaskEstimate>()).map(\.record)
        result.occurrenceEstimates = try context.fetch(FetchDescriptor<OccurrenceEstimate>()).map(\.record)
        result.goalSupports = try context.fetch(FetchDescriptor<GoalSupport>()).map(\.record)
        result.weeklyFocuses = try context.fetch(FetchDescriptor<WeeklyFocus>()).map(\.record)
        result.routineSchedules = try context.fetch(FetchDescriptor<RoutineSchedule>()).map(\.record)
        result.routineSessions = try context.fetch(FetchDescriptor<RoutineSession>()).map(\.record)
        result.activityAnnotations = try context.fetch(FetchDescriptor<ActivityAnnotation>()).map(\.record)
        result.nutritionPlans = try context.fetch(FetchDescriptor<NutritionPlan>()).map(\.record)
        result.options = try context.fetch(FetchDescriptor<AppOption>()).map(\.record)
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
            do {
                let rows = try context.fetch(FetchDescriptor<SourceLink>())
                let wanted = Dictionary(uniqueKeysWithValues: data.sourceLinks.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.sourceLinks where !existing.contains(record.id) { context.insert(SourceLink(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<PlanningCapacity>())
                let wanted = Dictionary(uniqueKeysWithValues: data.capacities.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.capacities where !existing.contains(record.id) { context.insert(PlanningCapacity(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<TaskEstimate>())
                let wanted = Dictionary(uniqueKeysWithValues: data.taskEstimates.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.taskEstimates where !existing.contains(record.id) { context.insert(TaskEstimate(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<OccurrenceEstimate>())
                let wanted = Dictionary(uniqueKeysWithValues: data.occurrenceEstimates.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.occurrenceEstimates where !existing.contains(record.id) { context.insert(OccurrenceEstimate(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<GoalSupport>())
                let wanted = Dictionary(uniqueKeysWithValues: data.goalSupports.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.goalSupports where !existing.contains(record.id) { context.insert(GoalSupport(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<WeeklyFocus>())
                let wanted = Dictionary(uniqueKeysWithValues: data.weeklyFocuses.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.weeklyFocuses where !existing.contains(record.id) { context.insert(WeeklyFocus(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<RoutineSchedule>())
                let wanted = Dictionary(uniqueKeysWithValues: data.routineSchedules.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.routineSchedules where !existing.contains(record.id) { context.insert(RoutineSchedule(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<RoutineSession>())
                let wanted = Dictionary(uniqueKeysWithValues: data.routineSessions.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.routineSessions where !existing.contains(record.id) { context.insert(RoutineSession(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<ActivityAnnotation>())
                let wanted = Dictionary(uniqueKeysWithValues: data.activityAnnotations.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.activityAnnotations where !existing.contains(record.id) { context.insert(ActivityAnnotation(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<NutritionPlan>())
                let wanted = Dictionary(uniqueKeysWithValues: data.nutritionPlans.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.nutritionPlans where !existing.contains(record.id) { context.insert(NutritionPlan(record)) }
            }
            do {
                let rows = try context.fetch(FetchDescriptor<AppOption>())
                let wanted = Dictionary(uniqueKeysWithValues: data.options.map { ($0.id, $0) })
                let existing = Set(rows.map(\.id))
                for row in rows {
                    if let record = wanted[row.id] { if row.record != record { row.update(record) } } else { context.delete(row) }
                }
                for record in data.options where !existing.contains(record.id) { context.insert(AppOption(record)) }
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
