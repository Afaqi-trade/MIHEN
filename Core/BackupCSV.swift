// Generated typed backup CSV dispatch and uniqueness validation.
import Foundation
extension BackupCodec {
    static func validateUnique(_ data: BackupDocument) throws {
        guard Set(data.preferences.map(\.id)).count == data.preferences.count, data.preferences.count <= 100_000, data.preferences.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.domains.map(\.id)).count == data.domains.count, data.domains.count <= 100_000, data.domains.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.subcategories.map(\.id)).count == data.subcategories.count, data.subcategories.count <= 100_000, data.subcategories.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.goals.map(\.id)).count == data.goals.count, data.goals.count <= 100_000, data.goals.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.milestones.map(\.id)).count == data.milestones.count, data.milestones.count <= 100_000, data.milestones.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.goalProgress.map(\.id)).count == data.goalProgress.count, data.goalProgress.count <= 100_000, data.goalProgress.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.tasks.map(\.id)).count == data.tasks.count, data.tasks.count <= 100_000, data.tasks.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.occurrences.map(\.id)).count == data.occurrences.count, data.occurrences.count <= 100_000, data.occurrences.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.routines.map(\.id)).count == data.routines.count, data.routines.count <= 100_000, data.routines.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.routineItems.map(\.id)).count == data.routineItems.count, data.routineItems.count <= 100_000, data.routineItems.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.projects.map(\.id)).count == data.projects.count, data.projects.count <= 100_000, data.projects.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.khatms.map(\.id)).count == data.khatms.count, data.khatms.count <= 100_000, data.khatms.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.readings.map(\.id)).count == data.readings.count, data.readings.count <= 100_000, data.readings.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.memorization.map(\.id)).count == data.memorization.count, data.memorization.count <= 100_000, data.memorization.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.memorizationReviews.map(\.id)).count == data.memorizationReviews.count, data.memorizationReviews.count <= 100_000, data.memorizationReviews.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.dhikr.map(\.id)).count == data.dhikr.count, data.dhikr.count <= 100_000, data.dhikr.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.fasts.map(\.id)).count == data.fasts.count, data.fasts.count <= 100_000, data.fasts.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.events.map(\.id)).count == data.events.count, data.events.count <= 100_000, data.events.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.journals.map(\.id)).count == data.journals.count, data.journals.count <= 100_000, data.journals.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.activities.map(\.id)).count == data.activities.count, data.activities.count <= 100_000, data.activities.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
        guard Set(data.notificationPreferences.map(\.id)).count == data.notificationPreferences.count, data.notificationPreferences.count <= 100_000, data.notificationPreferences.allSatisfy({ !$0.id.isEmpty && $0.id.count <= 150 }) else { throw PlanError.invalid("validation.duplicates") }
    }
    public static func exportCSV(_ data: BackupDocument) throws -> String {
        try validate(data)
        var rows = [["entity", "id", "payload"]]
        for record in data.preferences { rows.append(["UserPreferences", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.domains { rows.append(["LifeDomain", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.subcategories { rows.append(["Subcategory", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.goals { rows.append(["Goal", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.milestones { rows.append(["GoalMilestone", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.goalProgress { rows.append(["GoalProgressEntry", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.tasks { rows.append(["PlannedTask", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.occurrences { rows.append(["TaskOccurrence", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.routines { rows.append(["Routine", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.routineItems { rows.append(["RoutineItem", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.projects { rows.append(["Project", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.khatms { rows.append(["QuranKhatm", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.readings { rows.append(["QuranReadingLog", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.memorization { rows.append(["MemorizationItem", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.memorizationReviews { rows.append(["MemorizationReview", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.dhikr { rows.append(["DhikrCounter", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.fasts { rows.append(["FastingPlan", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.events { rows.append(["CalendarEvent", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.journals { rows.append(["JournalEntry", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.activities { rows.append(["DomainActivity", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        for record in data.notificationPreferences { rows.append(["NotificationPreference", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }
        return CSV.encode(rows)
    }
    public static func importCSV(_ text: String) throws -> BackupDocument {
        let rows = try CSV.parse(text)
        guard rows.first == ["entity", "id", "payload"] else { throw PlanError.invalid("validation.csvHeader") }
        var document = BackupDocument()
        for (index, row) in rows.dropFirst().enumerated() {
            guard row.count == 3 else { throw PlanError.invalid("CSV: \(index + 2)") }
            let bytes = Data(row[2].utf8)
            switch row[0] {
            case "UserPreferences":
                let value = try decoder().decode(UserPreferencesRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.preferences.append(value)
            case "LifeDomain":
                let value = try decoder().decode(LifeDomainRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.domains.append(value)
            case "Subcategory":
                let value = try decoder().decode(SubcategoryRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.subcategories.append(value)
            case "Goal":
                let value = try decoder().decode(GoalRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.goals.append(value)
            case "GoalMilestone":
                let value = try decoder().decode(GoalMilestoneRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.milestones.append(value)
            case "GoalProgressEntry":
                let value = try decoder().decode(GoalProgressEntryRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.goalProgress.append(value)
            case "PlannedTask":
                let value = try decoder().decode(PlannedTaskRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.tasks.append(value)
            case "TaskOccurrence":
                let value = try decoder().decode(TaskOccurrenceRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.occurrences.append(value)
            case "Routine":
                let value = try decoder().decode(RoutineRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.routines.append(value)
            case "RoutineItem":
                let value = try decoder().decode(RoutineItemRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.routineItems.append(value)
            case "Project":
                let value = try decoder().decode(ProjectRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.projects.append(value)
            case "QuranKhatm":
                let value = try decoder().decode(QuranKhatmRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.khatms.append(value)
            case "QuranReadingLog":
                let value = try decoder().decode(QuranReadingLogRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.readings.append(value)
            case "MemorizationItem":
                let value = try decoder().decode(MemorizationItemRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.memorization.append(value)
            case "MemorizationReview":
                let value = try decoder().decode(MemorizationReviewRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.memorizationReviews.append(value)
            case "DhikrCounter":
                let value = try decoder().decode(DhikrCounterRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.dhikr.append(value)
            case "FastingPlan":
                let value = try decoder().decode(FastingPlanRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.fasts.append(value)
            case "CalendarEvent":
                let value = try decoder().decode(CalendarEventRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.events.append(value)
            case "JournalEntry":
                let value = try decoder().decode(JournalEntryRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.journals.append(value)
            case "DomainActivity":
                let value = try decoder().decode(DomainActivityRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.activities.append(value)
            case "NotificationPreference":
                let value = try decoder().decode(NotificationPreferenceRecord.self, from: bytes)
                guard value.id == row[1] else { throw PlanError.invalid("validation.data") }
                document.notificationPreferences.append(value)
            default: throw PlanError.invalid("validation.csvEntity")
            }
        }
        try validate(document)
        return document
    }
}
