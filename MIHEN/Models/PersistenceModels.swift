// Generated SwiftData persistence rows.
import Foundation
import SwiftData

@Model final class UserPreferences {
    @Attribute(.unique) var id: String
    var name: String
    var language: String
    var theme: String
    var timeZoneID: String
    var hijriOffset: Int
    var showHijri: Bool
    var onboarded: Bool
    var lockEnabled: Bool
    var restWeekdays: [Int]
    var remindersEnabled: Bool
    var reminderHour: Int
    var quietStart: Int
    var quietEnd: Int
    init(_ record: UserPreferencesRecord) {
        self.id = record.id
        self.name = record.name
        self.language = record.language
        self.theme = record.theme
        self.timeZoneID = record.timeZoneID
        self.hijriOffset = record.hijriOffset
        self.showHijri = record.showHijri
        self.onboarded = record.onboarded
        self.lockEnabled = record.lockEnabled
        self.restWeekdays = record.restWeekdays
        self.remindersEnabled = record.remindersEnabled
        self.reminderHour = record.reminderHour
        self.quietStart = record.quietStart
        self.quietEnd = record.quietEnd
    }
    var record: UserPreferencesRecord { .init(id: id, name: name, language: language, theme: theme, timeZoneID: timeZoneID, hijriOffset: hijriOffset, showHijri: showHijri, onboarded: onboarded, lockEnabled: lockEnabled, restWeekdays: restWeekdays, remindersEnabled: remindersEnabled, reminderHour: reminderHour, quietStart: quietStart, quietEnd: quietEnd) }
    func update(_ record: UserPreferencesRecord) {
        self.name = record.name
        self.language = record.language
        self.theme = record.theme
        self.timeZoneID = record.timeZoneID
        self.hijriOffset = record.hijriOffset
        self.showHijri = record.showHijri
        self.onboarded = record.onboarded
        self.lockEnabled = record.lockEnabled
        self.restWeekdays = record.restWeekdays
        self.remindersEnabled = record.remindersEnabled
        self.reminderHour = record.reminderHour
        self.quietStart = record.quietStart
        self.quietEnd = record.quietEnd
    }
}

@Model final class LifeDomain {
    @Attribute(.unique) var id: String
    var key: String
    var enabled: Bool
    var rank: Int
    var vision: String
    init(_ record: LifeDomainRecord) {
        self.id = record.id
        self.key = record.key
        self.enabled = record.enabled
        self.rank = record.rank
        self.vision = record.vision
    }
    var record: LifeDomainRecord { .init(id: id, key: key, enabled: enabled, rank: rank, vision: vision) }
    func update(_ record: LifeDomainRecord) {
        self.key = record.key
        self.enabled = record.enabled
        self.rank = record.rank
        self.vision = record.vision
    }
}

@Model final class Subcategory {
    @Attribute(.unique) var id: String
    var domainID: String
    var title: String
    init(_ record: SubcategoryRecord) {
        self.id = record.id
        self.domainID = record.domainID
        self.title = record.title
    }
    var record: SubcategoryRecord { .init(id: id, domainID: domainID, title: title) }
    func update(_ record: SubcategoryRecord) {
        self.domainID = record.domainID
        self.title = record.title
    }
}

@Model final class Goal {
    @Attribute(.unique) var id: String
    var title: String
    var domainIDs: [String]
    var parentID: String?
    var subcategoryID: String?
    var horizon: String
    var start: Date
    var end: Date
    var target: Double
    var unit: String
    var priority: Int
    var archived: Bool
    var notes: String
    init(_ record: GoalRecord) {
        self.id = record.id
        self.title = record.title
        self.domainIDs = record.domainIDs
        self.parentID = record.parentID
        self.subcategoryID = record.subcategoryID
        self.horizon = record.horizon
        self.start = record.start
        self.end = record.end
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.archived = record.archived
        self.notes = record.notes
    }
    var record: GoalRecord { .init(id: id, title: title, domainIDs: domainIDs, parentID: parentID, subcategoryID: subcategoryID, horizon: horizon, start: start, end: end, target: target, unit: unit, priority: priority, archived: archived, notes: notes) }
    func update(_ record: GoalRecord) {
        self.title = record.title
        self.domainIDs = record.domainIDs
        self.parentID = record.parentID
        self.subcategoryID = record.subcategoryID
        self.horizon = record.horizon
        self.start = record.start
        self.end = record.end
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.archived = record.archived
        self.notes = record.notes
    }
}

@Model final class GoalMilestone {
    @Attribute(.unique) var id: String
    var goalID: String
    var title: String
    var due: Date
    var done: Bool
    init(_ record: GoalMilestoneRecord) {
        self.id = record.id
        self.goalID = record.goalID
        self.title = record.title
        self.due = record.due
        self.done = record.done
    }
    var record: GoalMilestoneRecord { .init(id: id, goalID: goalID, title: title, due: due, done: done) }
    func update(_ record: GoalMilestoneRecord) {
        self.goalID = record.goalID
        self.title = record.title
        self.due = record.due
        self.done = record.done
    }
}

@Model final class GoalProgressEntry {
    @Attribute(.unique) var id: String
    var goalID: String
    var date: Date
    var amount: Double
    var note: String
    init(_ record: GoalProgressEntryRecord) {
        self.id = record.id
        self.goalID = record.goalID
        self.date = record.date
        self.amount = record.amount
        self.note = record.note
    }
    var record: GoalProgressEntryRecord { .init(id: id, goalID: goalID, date: date, amount: amount, note: note) }
    func update(_ record: GoalProgressEntryRecord) {
        self.goalID = record.goalID
        self.date = record.date
        self.amount = record.amount
        self.note = record.note
    }
}

@Model final class PlannedTask {
    @Attribute(.unique) var id: String
    var title: String
    var domainID: String
    var goalID: String?
    var start: Date
    var end: Date?
    var recurrence: String
    var target: Double
    var unit: String
    var priority: Int
    var isHabit: Bool
    var archived: Bool
    var weekdays: [Int]
    var notes: String
    init(_ record: PlannedTaskRecord) {
        self.id = record.id
        self.title = record.title
        self.domainID = record.domainID
        self.goalID = record.goalID
        self.start = record.start
        self.end = record.end
        self.recurrence = record.recurrence
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.isHabit = record.isHabit
        self.archived = record.archived
        self.weekdays = record.weekdays
        self.notes = record.notes
    }
    var record: PlannedTaskRecord { .init(id: id, title: title, domainID: domainID, goalID: goalID, start: start, end: end, recurrence: recurrence, target: target, unit: unit, priority: priority, isHabit: isHabit, archived: archived, weekdays: weekdays, notes: notes) }
    func update(_ record: PlannedTaskRecord) {
        self.title = record.title
        self.domainID = record.domainID
        self.goalID = record.goalID
        self.start = record.start
        self.end = record.end
        self.recurrence = record.recurrence
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.isHabit = record.isHabit
        self.archived = record.archived
        self.weekdays = record.weekdays
        self.notes = record.notes
    }
}

@Model final class TaskOccurrence {
    @Attribute(.unique) var id: String
    var taskID: String
    var day: String
    var title: String
    var domainID: String
    var goalID: String?
    var target: Double
    var unit: String
    var priority: Int
    var value: Double
    var status: String
    var originalDay: String?
    init(_ record: TaskOccurrenceRecord) {
        self.id = record.id
        self.taskID = record.taskID
        self.day = record.day
        self.title = record.title
        self.domainID = record.domainID
        self.goalID = record.goalID
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.value = record.value
        self.status = record.status
        self.originalDay = record.originalDay
    }
    var record: TaskOccurrenceRecord { .init(id: id, taskID: taskID, day: day, title: title, domainID: domainID, goalID: goalID, target: target, unit: unit, priority: priority, value: value, status: status, originalDay: originalDay) }
    func update(_ record: TaskOccurrenceRecord) {
        self.taskID = record.taskID
        self.day = record.day
        self.title = record.title
        self.domainID = record.domainID
        self.goalID = record.goalID
        self.target = record.target
        self.unit = record.unit
        self.priority = record.priority
        self.value = record.value
        self.status = record.status
        self.originalDay = record.originalDay
    }
}

@Model final class Routine {
    @Attribute(.unique) var id: String
    var title: String
    var domainID: String
    init(_ record: RoutineRecord) {
        self.id = record.id
        self.title = record.title
        self.domainID = record.domainID
    }
    var record: RoutineRecord { .init(id: id, title: title, domainID: domainID) }
    func update(_ record: RoutineRecord) {
        self.title = record.title
        self.domainID = record.domainID
    }
}

@Model final class RoutineItem {
    @Attribute(.unique) var id: String
    var routineID: String
    var taskID: String
    var rank: Int
    init(_ record: RoutineItemRecord) {
        self.id = record.id
        self.routineID = record.routineID
        self.taskID = record.taskID
        self.rank = record.rank
    }
    var record: RoutineItemRecord { .init(id: id, routineID: routineID, taskID: taskID, rank: rank) }
    func update(_ record: RoutineItemRecord) {
        self.routineID = record.routineID
        self.taskID = record.taskID
        self.rank = record.rank
    }
}

@Model final class Project {
    @Attribute(.unique) var id: String
    var title: String
    var goalID: String?
    var domainID: String
    var notes: String
    var archived: Bool
    init(_ record: ProjectRecord) {
        self.id = record.id
        self.title = record.title
        self.goalID = record.goalID
        self.domainID = record.domainID
        self.notes = record.notes
        self.archived = record.archived
    }
    var record: ProjectRecord { .init(id: id, title: title, goalID: goalID, domainID: domainID, notes: notes, archived: archived) }
    func update(_ record: ProjectRecord) {
        self.title = record.title
        self.goalID = record.goalID
        self.domainID = record.domainID
        self.notes = record.notes
        self.archived = record.archived
    }
}

@Model final class QuranKhatm {
    @Attribute(.unique) var id: String
    var title: String
    var kind: String
    var start: Date
    var end: Date
    var totalPages: Int
    var notes: String
    var completedAt: Date?
    init(_ record: QuranKhatmRecord) {
        self.id = record.id
        self.title = record.title
        self.kind = record.kind
        self.start = record.start
        self.end = record.end
        self.totalPages = record.totalPages
        self.notes = record.notes
        self.completedAt = record.completedAt
    }
    var record: QuranKhatmRecord { .init(id: id, title: title, kind: kind, start: start, end: end, totalPages: totalPages, notes: notes, completedAt: completedAt) }
    func update(_ record: QuranKhatmRecord) {
        self.title = record.title
        self.kind = record.kind
        self.start = record.start
        self.end = record.end
        self.totalPages = record.totalPages
        self.notes = record.notes
        self.completedAt = record.completedAt
    }
}

@Model final class QuranReadingLog {
    @Attribute(.unique) var id: String
    var khatmID: String
    var date: Date
    var pages: Int
    init(_ record: QuranReadingLogRecord) {
        self.id = record.id
        self.khatmID = record.khatmID
        self.date = record.date
        self.pages = record.pages
    }
    var record: QuranReadingLogRecord { .init(id: id, khatmID: khatmID, date: date, pages: pages) }
    func update(_ record: QuranReadingLogRecord) {
        self.khatmID = record.khatmID
        self.date = record.date
        self.pages = record.pages
    }
}

@Model final class MemorizationItem {
    @Attribute(.unique) var id: String
    var title: String
    var firstVerse: Int
    var lastVerse: Int
    var learnedVerses: Int
    var difficulty: Int
    var intervals: [Int]
    var notes: String
    init(_ record: MemorizationItemRecord) {
        self.id = record.id
        self.title = record.title
        self.firstVerse = record.firstVerse
        self.lastVerse = record.lastVerse
        self.learnedVerses = record.learnedVerses
        self.difficulty = record.difficulty
        self.intervals = record.intervals
        self.notes = record.notes
    }
    var record: MemorizationItemRecord { .init(id: id, title: title, firstVerse: firstVerse, lastVerse: lastVerse, learnedVerses: learnedVerses, difficulty: difficulty, intervals: intervals, notes: notes) }
    func update(_ record: MemorizationItemRecord) {
        self.title = record.title
        self.firstVerse = record.firstVerse
        self.lastVerse = record.lastVerse
        self.learnedVerses = record.learnedVerses
        self.difficulty = record.difficulty
        self.intervals = record.intervals
        self.notes = record.notes
    }
}

@Model final class MemorizationReview {
    @Attribute(.unique) var id: String
    var itemID: String
    var date: Date
    var difficulty: Int
    init(_ record: MemorizationReviewRecord) {
        self.id = record.id
        self.itemID = record.itemID
        self.date = record.date
        self.difficulty = record.difficulty
    }
    var record: MemorizationReviewRecord { .init(id: id, itemID: itemID, date: date, difficulty: difficulty) }
    func update(_ record: MemorizationReviewRecord) {
        self.itemID = record.itemID
        self.date = record.date
        self.difficulty = record.difficulty
    }
}

@Model final class DhikrCounter {
    @Attribute(.unique) var id: String
    var title: String
    var day: String
    var target: Int
    var value: Int
    init(_ record: DhikrCounterRecord) {
        self.id = record.id
        self.title = record.title
        self.day = record.day
        self.target = record.target
        self.value = record.value
    }
    var record: DhikrCounterRecord { .init(id: id, title: title, day: day, target: target, value: value) }
    func update(_ record: DhikrCounterRecord) {
        self.title = record.title
        self.day = record.day
        self.target = record.target
        self.value = record.value
    }
}

@Model final class FastingPlan {
    @Attribute(.unique) var id: String
    var date: Date
    var title: String
    var status: String
    var notes: String
    init(_ record: FastingPlanRecord) {
        self.id = record.id
        self.date = record.date
        self.title = record.title
        self.status = record.status
        self.notes = record.notes
    }
    var record: FastingPlanRecord { .init(id: id, date: date, title: title, status: status, notes: notes) }
    func update(_ record: FastingPlanRecord) {
        self.date = record.date
        self.title = record.title
        self.status = record.status
        self.notes = record.notes
    }
}

@Model final class CalendarEvent {
    @Attribute(.unique) var id: String
    var title: String
    var date: Date
    var end: Date
    var recurrence: String
    var notes: String
    init(_ record: CalendarEventRecord) {
        self.id = record.id
        self.title = record.title
        self.date = record.date
        self.end = record.end
        self.recurrence = record.recurrence
        self.notes = record.notes
    }
    var record: CalendarEventRecord { .init(id: id, title: title, date: date, end: end, recurrence: recurrence, notes: notes) }
    func update(_ record: CalendarEventRecord) {
        self.title = record.title
        self.date = record.date
        self.end = record.end
        self.recurrence = record.recurrence
        self.notes = record.notes
    }
}

@Model final class JournalEntry {
    @Attribute(.unique) var id: String
    var date: Date
    var domainID: String?
    var kind: String
    var text: String
    init(_ record: JournalEntryRecord) {
        self.id = record.id
        self.date = record.date
        self.domainID = record.domainID
        self.kind = record.kind
        self.text = record.text
    }
    var record: JournalEntryRecord { .init(id: id, date: date, domainID: domainID, kind: kind, text: text) }
    func update(_ record: JournalEntryRecord) {
        self.date = record.date
        self.domainID = record.domainID
        self.kind = record.kind
        self.text = record.text
    }
}

@Model final class DomainActivity {
    @Attribute(.unique) var id: String
    var domainID: String
    var date: Date
    var kind: String
    var amount: Double
    var unit: String
    var note: String
    init(_ record: DomainActivityRecord) {
        self.id = record.id
        self.domainID = record.domainID
        self.date = record.date
        self.kind = record.kind
        self.amount = record.amount
        self.unit = record.unit
        self.note = record.note
    }
    var record: DomainActivityRecord { .init(id: id, domainID: domainID, date: date, kind: kind, amount: amount, unit: unit, note: note) }
    func update(_ record: DomainActivityRecord) {
        self.domainID = record.domainID
        self.date = record.date
        self.kind = record.kind
        self.amount = record.amount
        self.unit = record.unit
        self.note = record.note
    }
}

@Model final class NotificationPreference {
    @Attribute(.unique) var id: String
    var kind: String
    var enabled: Bool
    var hour: Int
    var minute: Int
    init(_ record: NotificationPreferenceRecord) {
        self.id = record.id
        self.kind = record.kind
        self.enabled = record.enabled
        self.hour = record.hour
        self.minute = record.minute
    }
    var record: NotificationPreferenceRecord { .init(id: id, kind: kind, enabled: enabled, hour: hour, minute: minute) }
    func update(_ record: NotificationPreferenceRecord) {
        self.kind = record.kind
        self.enabled = record.enabled
        self.hour = record.hour
        self.minute = record.minute
    }
}

@Model final class SourceLink {
    @Attribute(.unique) var id: String
    var sourceKind: String
    var sourceID: String
    var occurrenceID: String
    var previousValue: Double
    var sourceDate: Date
    var day: String
    init(_ record: SourceLinkRecord) {
        self.id = record.id
        self.sourceKind = record.sourceKind
        self.sourceID = record.sourceID
        self.occurrenceID = record.occurrenceID
        self.previousValue = record.previousValue
        self.sourceDate = record.sourceDate
        self.day = record.day
    }
    var record: SourceLinkRecord { .init(id: id, sourceKind: sourceKind, sourceID: sourceID, occurrenceID: occurrenceID, previousValue: previousValue, sourceDate: sourceDate, day: day) }
    func update(_ record: SourceLinkRecord) {
        self.sourceKind = record.sourceKind
        self.sourceID = record.sourceID
        self.occurrenceID = record.occurrenceID
        self.previousValue = record.previousValue
        self.sourceDate = record.sourceDate
        self.day = record.day
    }
}

@Model final class PlanningCapacity {
    @Attribute(.unique) var id: String
    var weekday: Int
    var minutes: Int
    init(_ record: PlanningCapacityRecord) {
        self.id = record.id
        self.weekday = record.weekday
        self.minutes = record.minutes
    }
    var record: PlanningCapacityRecord { .init(id: id, weekday: weekday, minutes: minutes) }
    func update(_ record: PlanningCapacityRecord) {
        self.weekday = record.weekday
        self.minutes = record.minutes
    }
}

@Model final class TaskEstimate {
    @Attribute(.unique) var id: String
    var taskID: String
    var minutes: Double
    init(_ record: TaskEstimateRecord) {
        self.id = record.id
        self.taskID = record.taskID
        self.minutes = record.minutes
    }
    var record: TaskEstimateRecord { .init(id: id, taskID: taskID, minutes: minutes) }
    func update(_ record: TaskEstimateRecord) {
        self.taskID = record.taskID
        self.minutes = record.minutes
    }
}

@Model final class OccurrenceEstimate {
    @Attribute(.unique) var id: String
    var occurrenceID: String
    var minutes: Double
    init(_ record: OccurrenceEstimateRecord) {
        self.id = record.id
        self.occurrenceID = record.occurrenceID
        self.minutes = record.minutes
    }
    var record: OccurrenceEstimateRecord { .init(id: id, occurrenceID: occurrenceID, minutes: minutes) }
    func update(_ record: OccurrenceEstimateRecord) {
        self.occurrenceID = record.occurrenceID
        self.minutes = record.minutes
    }
}

@Model final class GoalSupport {
    @Attribute(.unique) var id: String
    var goalID: String
    var taskID: String
    init(_ record: GoalSupportRecord) {
        self.id = record.id
        self.goalID = record.goalID
        self.taskID = record.taskID
    }
    var record: GoalSupportRecord { .init(id: id, goalID: goalID, taskID: taskID) }
    func update(_ record: GoalSupportRecord) {
        self.goalID = record.goalID
        self.taskID = record.taskID
    }
}

@Model final class WeeklyFocus {
    @Attribute(.unique) var id: String
    var week: String
    var kind: String
    var referenceID: String
    var title: String
    var rank: Int
    init(_ record: WeeklyFocusRecord) {
        self.id = record.id
        self.week = record.week
        self.kind = record.kind
        self.referenceID = record.referenceID
        self.title = record.title
        self.rank = record.rank
    }
    var record: WeeklyFocusRecord { .init(id: id, week: week, kind: kind, referenceID: referenceID, title: title, rank: rank) }
    func update(_ record: WeeklyFocusRecord) {
        self.week = record.week
        self.kind = record.kind
        self.referenceID = record.referenceID
        self.title = record.title
        self.rank = record.rank
    }
}

@Model final class RoutineSchedule {
    @Attribute(.unique) var id: String
    var routineID: String
    var weekdays: [Int]
    var paused: Bool
    init(_ record: RoutineScheduleRecord) {
        self.id = record.id
        self.routineID = record.routineID
        self.weekdays = record.weekdays
        self.paused = record.paused
    }
    var record: RoutineScheduleRecord { .init(id: id, routineID: routineID, weekdays: weekdays, paused: paused) }
    func update(_ record: RoutineScheduleRecord) {
        self.routineID = record.routineID
        self.weekdays = record.weekdays
        self.paused = record.paused
    }
}

@Model final class RoutineSession {
    @Attribute(.unique) var id: String
    var routineID: String
    var day: String
    var taskIDs: [String]
    var position: Int
    init(_ record: RoutineSessionRecord) {
        self.id = record.id
        self.routineID = record.routineID
        self.day = record.day
        self.taskIDs = record.taskIDs
        self.position = record.position
    }
    var record: RoutineSessionRecord { .init(id: id, routineID: routineID, day: day, taskIDs: taskIDs, position: position) }
    func update(_ record: RoutineSessionRecord) {
        self.routineID = record.routineID
        self.day = record.day
        self.taskIDs = record.taskIDs
        self.position = record.position
    }
}

@Model final class ActivityAnnotation {
    @Attribute(.unique) var id: String
    var activityID: String
    var meal: String
    var title: String
    var lastUsed: Date
    init(_ record: ActivityAnnotationRecord) {
        self.id = record.id
        self.activityID = record.activityID
        self.meal = record.meal
        self.title = record.title
        self.lastUsed = record.lastUsed
    }
    var record: ActivityAnnotationRecord { .init(id: id, activityID: activityID, meal: meal, title: title, lastUsed: lastUsed) }
    func update(_ record: ActivityAnnotationRecord) {
        self.activityID = record.activityID
        self.meal = record.meal
        self.title = record.title
        self.lastUsed = record.lastUsed
    }
}

@Model final class NutritionPlan {
    @Attribute(.unique) var id: String
    var date: Date
    var kind: String
    var amount: Double
    var unit: String
    var meal: String
    var title: String
    init(_ record: NutritionPlanRecord) {
        self.id = record.id
        self.date = record.date
        self.kind = record.kind
        self.amount = record.amount
        self.unit = record.unit
        self.meal = record.meal
        self.title = record.title
    }
    var record: NutritionPlanRecord { .init(id: id, date: date, kind: kind, amount: amount, unit: unit, meal: meal, title: title) }
    func update(_ record: NutritionPlanRecord) {
        self.date = record.date
        self.kind = record.kind
        self.amount = record.amount
        self.unit = record.unit
        self.meal = record.meal
        self.title = record.title
    }
}

@Model final class AppOption {
    @Attribute(.unique) var id: String
    var key: String
    var value: String
    init(_ record: AppOptionRecord) {
        self.id = record.id
        self.key = record.key
        self.value = record.value
    }
    var record: AppOptionRecord { .init(id: id, key: key, value: value) }
    func update(_ record: AppOptionRecord) {
        self.key = record.key
        self.value = record.value
    }
}

enum MihenSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [UserPreferences.self, LifeDomain.self, Subcategory.self, Goal.self, GoalMilestone.self, GoalProgressEntry.self, PlannedTask.self, TaskOccurrence.self, Routine.self, RoutineItem.self, Project.self, QuranKhatm.self, QuranReadingLog.self, MemorizationItem.self, MemorizationReview.self, DhikrCounter.self, FastingPlan.self, CalendarEvent.self, JournalEntry.self, DomainActivity.self, NotificationPreference.self] }
}
enum MihenSchema: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [UserPreferences.self, LifeDomain.self, Subcategory.self, Goal.self, GoalMilestone.self, GoalProgressEntry.self, PlannedTask.self, TaskOccurrence.self, Routine.self, RoutineItem.self, Project.self, QuranKhatm.self, QuranReadingLog.self, MemorizationItem.self, MemorizationReview.self, DhikrCounter.self, FastingPlan.self, CalendarEvent.self, JournalEntry.self, DomainActivity.self, NotificationPreference.self, SourceLink.self, PlanningCapacity.self, TaskEstimate.self, OccurrenceEstimate.self, GoalSupport.self, WeeklyFocus.self, RoutineSchedule.self, RoutineSession.self, ActivityAnnotation.self, NutritionPlan.self, AppOption.self] }
}
enum MihenMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [MihenSchemaV1.self, MihenSchema.self] }
    static var stages: [MigrationStage] { [.lightweight(fromVersion: MihenSchemaV1.self, toVersion: MihenSchema.self)] }
}
