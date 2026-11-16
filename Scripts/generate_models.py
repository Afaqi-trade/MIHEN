"""Generate matching Codable DTOs and SwiftData rows from one schema. No dependencies."""
from pathlib import Path
# Field names, Swift type, default expression. UUID references are validated by BackupCodec.
S = {
'UserPreferences':[('name','String','""'),('language','String','"tr"'),('theme','String','"system"'),('timeZoneID','String','TimeZone.current.identifier'),('hijriOffset','Int','0'),('showHijri','Bool','false'),('onboarded','Bool','false'),('lockEnabled','Bool','false'),('restWeekdays','[Int]','[]'),('remindersEnabled','Bool','false'),('reminderHour','Int','9'),('quietStart','Int','22'),('quietEnd','Int','8')],
'LifeDomain':[('key','String','""'),('enabled','Bool','true'),('rank','Int','0'),('vision','String','""')],
'Subcategory':[('domainID','String','""'),('title','String','""')],
'Goal':[('title','String','""'),('domainIDs','[String]','[]'),('parentID','String?','nil'),('subcategoryID','String?','nil'),('horizon','String','"year"'),('start','Date','Date()'),('end','Date','Date()'),('target','Double','1'),('unit','String','"count"'),('priority','Int','1'),('archived','Bool','false'),('notes','String','""')],
'GoalMilestone':[('goalID','String','""'),('title','String','""'),('due','Date','Date()'),('done','Bool','false')],
'GoalProgressEntry':[('goalID','String','""'),('date','Date','Date()'),('amount','Double','0'),('note','String','""')],
'PlannedTask':[('title','String','""'),('domainID','String','""'),('goalID','String?','nil'),('start','Date','Date()'),('end','Date?','nil'),('recurrence','String','"none"'),('target','Double','1'),('unit','String','"count"'),('priority','Int','1'),('isHabit','Bool','false'),('archived','Bool','false'),('weekdays','[Int]','[]'),('notes','String','""')],
'TaskOccurrence':[('taskID','String','""'),('day','String','""'),('title','String','""'),('domainID','String','""'),('goalID','String?','nil'),('target','Double','1'),('unit','String','"count"'),('priority','Int','1'),('value','Double','0'),('status','String','"planned"'),('originalDay','String?','nil')],
'Routine':[('title','String','""'),('domainID','String','""')],
'RoutineItem':[('routineID','String','""'),('taskID','String','""'),('rank','Int','0')],
'Project':[('title','String','""'),('goalID','String?','nil'),('domainID','String','""'),('notes','String','""'),('archived','Bool','false')],
'QuranKhatm':[('title','String','""'),('kind','String','"reading"'),('start','Date','Date()'),('end','Date','Date()'),('totalPages','Int','604'),('notes','String','""'),('completedAt','Date?','nil')],
'QuranReadingLog':[('khatmID','String','""'),('date','Date','Date()'),('pages','Int','0')],
'MemorizationItem':[('title','String','""'),('firstVerse','Int','1'),('lastVerse','Int','1'),('learnedVerses','Int','0'),('difficulty','Int','1'),('intervals','[Int]','[1, 3, 7, 14, 30]'),('notes','String','""')],
'MemorizationReview':[('itemID','String','""'),('date','Date','Date()'),('difficulty','Int','1')],
'DhikrCounter':[('title','String','""'),('day','String','""'),('target','Int','100'),('value','Int','0')],
'FastingPlan':[('date','Date','Date()'),('title','String','""'),('status','String','"planned"'),('notes','String','""')],
'CalendarEvent':[('title','String','""'),('date','Date','Date()'),('end','Date','Date()'),('recurrence','String','"none"'),('notes','String','""')],
'JournalEntry':[('date','Date','Date()'),('domainID','String?','nil'),('kind','String','"note"'),('text','String','""')],
'DomainActivity':[('domainID','String','""'),('date','Date','Date()'),('kind','String','"other"'),('amount','Double','0'),('unit','String','"count"'),('note','String','""')],
'NotificationPreference':[('kind','String','"daily"'),('enabled','Bool','false'),('hour','Int','9'),('minute','Int','0')]
}

# V1 entity definitions above are frozen. V2 adds independent entities only.
V1_NAMES = tuple(S)
S.update({
'SourceLink':[('sourceKind','String','""'),('sourceID','String','""'),('occurrenceID','String','""'),('previousValue','Double','0')],
'PlanningCapacity':[('weekday','Int','1'),('minutes','Int','0')],
'TaskEstimate':[('taskID','String','""'),('minutes','Double','0')],
'OccurrenceEstimate':[('occurrenceID','String','""'),('minutes','Double','0')],
'GoalSupport':[('goalID','String','""'),('taskID','String','""')],
'WeeklyFocus':[('week','String','""'),('kind','String','"goal"'),('referenceID','String','""'),('title','String','""'),('rank','Int','0')],
'RoutineSchedule':[('routineID','String','""'),('weekdays','[Int]','[1,2,3,4,5,6,7]'),('paused','Bool','false')],
'RoutineSession':[('routineID','String','""'),('day','String','""'),('taskIDs','[String]','[]'),('position','Int','0')],
'ActivityAnnotation':[('activityID','String','""'),('meal','String','"other"'),('title','String','""')],
'NutritionPlan':[('date','Date','Date()'),('kind','String','"food"'),('amount','Double','0'),('unit','String','"kcal"'),('meal','String','"other"'),('title','String','""')],
'AppOption':[('key','String','""'),('value','String','""')]
})
arrays = {'UserPreferences':'preferences','LifeDomain':'domains','Subcategory':'subcategories','Goal':'goals','GoalMilestone':'milestones','GoalProgressEntry':'goalProgress','PlannedTask':'tasks','TaskOccurrence':'occurrences','Routine':'routines','RoutineItem':'routineItems','Project':'projects','QuranKhatm':'khatms','QuranReadingLog':'readings','MemorizationItem':'memorization','MemorizationReview':'memorizationReviews','DhikrCounter':'dhikr','FastingPlan':'fasts','CalendarEvent':'events','JournalEntry':'journals','DomainActivity':'activities','NotificationPreference':'notificationPreferences'}
arrays.update({'SourceLink':'sourceLinks','PlanningCapacity':'capacities','TaskEstimate':'taskEstimates','OccurrenceEstimate':'occurrenceEstimates','GoalSupport':'goalSupports','WeeklyFocus':'weeklyFocuses','RoutineSchedule':'routineSchedules','RoutineSession':'routineSessions','ActivityAnnotation':'activityAnnotations','NutritionPlan':'nutritionPlans','AppOption':'options'})
core='// Generated by Scripts/generate_models.py; change the schema there.\nimport Foundation\n\n'
models='// Generated SwiftData persistence rows.\nimport Foundation\nimport SwiftData\n\n'
for name, fs in S.items():
    fields=[('id','String','UUID().uuidString')]+fs
    core+=f'public struct {name}Record: Codable, Identifiable, Equatable, Sendable {{\n'
    core+=''.join(f'    public var {n}: {t}\n' for n,t,d in fields)
    core+='    public init('+', '.join(f'{n}: {t} = {d}' for n,t,d in fields)+') {\n'
    core+=''.join(f'        self.{n} = {n}\n' for n,t,d in fields)+'    }\n}\n\n'
    models+=f'@Model final class {name} {{\n'
    models+=''.join(f'    {"@Attribute(.unique) " if n=="id" else ""}var {n}: {t}\n' for n,t,d in fields)
    models+=f'    init(_ record: {name}Record) {{\n'+''.join(f'        self.{n} = record.{n}\n' for n,t,d in fields)+'    }\n'
    models+=f'    var record: {name}Record {{ .init('+', '.join(f'{n}: {n}' for n,t,d in fields)+') }\n'
    models+=f'    func update(_ record: {name}Record) {{\n'+''.join(f'        self.{n} = record.{n}\n' for n,t,d in fields if n!='id')+'    }\n}\n\n'
core+='public struct BackupDocument: Codable, Equatable, Sendable {\n    public var version: Int = 2\n    public var exportedAt: Date = Date()\n'
core+=''.join(f'    public var {arrays[n]}: [{n}Record] = []\n' for n in S)
core+='    public init() {}\n'
core+='    private enum CodingKeys: String, CodingKey { case version, exportedAt, '+', '.join(arrays.values())+' }\n'
core+='    public init(from decoder: Decoder) throws {\n        let box = try decoder.container(keyedBy: CodingKeys.self)\n        let oldVersion = try box.decode(Int.self, forKey: .version)\n        guard [1,2].contains(oldVersion) else { throw PlanError.invalid("validation.version") }\n        version = 2\n        exportedAt = try box.decode(Date.self, forKey: .exportedAt)\n'
for n in S:
    arr=arrays[n]
    if n in V1_NAMES: core+=f'        {arr} = try box.decode([{n}Record].self, forKey: .{arr})\n'
    else: core+=f'        {arr} = oldVersion == 1 ? (try box.decodeIfPresent([{n}Record].self, forKey: .{arr}) ?? []) : try box.decode([{n}Record].self, forKey: .{arr})\n'
core+='    }\n}\n'
Path('Core/Records.swift').write_text(core)
models+='enum MihenSchemaV1: VersionedSchema {\n    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }\n    static var models: [any PersistentModel.Type] { ['+', '.join(n+'.self' for n in V1_NAMES)+'] }\n}\n'
models+='enum MihenSchema: VersionedSchema {\n    static var versionIdentifier: Schema.Version { .init(2, 0, 0) }\n    static var models: [any PersistentModel.Type] { ['+', '.join(n+'.self' for n in S)+'] }\n}\nenum MihenMigrationPlan: SchemaMigrationPlan {\n    static var schemas: [any VersionedSchema.Type] { [MihenSchemaV1.self, MihenSchema.self] }\n    static var stages: [MigrationStage] { [.lightweight(fromVersion: MihenSchemaV1.self, toVersion: MihenSchema.self)] }\n}\n'
Path('MIHEN/Models/PersistenceModels.swift').write_text(models)
repo='''import Foundation
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
'''
repo+=''.join(f'        result.{arrays[n]} = try context.fetch(FetchDescriptor<{n}>()).map(\\.record)\n' for n in S)
repo+='        return result\n    }\n    func save(_ data: BackupDocument) throws {\n        try BackupCodec.validate(data)\n        do {\n'
for n in S:
    arr=arrays[n]
    repo+='''            do {
'''+f'                let rows = try context.fetch(FetchDescriptor<{n}>())\n                let wanted = Dictionary(uniqueKeysWithValues: data.{arr}.map {{ ($0.id, $0) }})\n                let existing = Set(rows.map(\\.id))\n                for row in rows {{\n                    if let record = wanted[row.id] {{ if row.record != record {{ row.update(record) }} }} else {{ context.delete(row) }}\n                }}\n                for record in data.{arr} where !existing.contains(record.id) {{ context.insert({n}(record)) }}\n'+'            }\n'
repo+='''            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
'''
Path('MIHEN/Services/Repository.swift').write_text(repo)
