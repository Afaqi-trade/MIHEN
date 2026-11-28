import Foundation

public enum LifeArea: String, CaseIterable, Codable, Sendable {
    case spiritual, learning, character, family, health, career, finance, service
    public var titleTR: String {
        switch self {
        case .spiritual: return "Maneviyat"
        case .learning: return "Öğrenme ve Gelişim"
        case .character: return "Karakter ve İç Denge"
        case .family: return "Aile ve İlişkiler"
        case .health: return "Sağlık ve Yaşam"
        case .career: return "İş ve Üretim"
        case .finance: return "Maddi Yaşam ve Paylaşım"
        case .service: return "Toplumsal Katkı"
        }
    }
    public var titleEN: String {
        switch self {
        case .spiritual: return "Spirituality"
        case .learning: return "Learning and Growth"
        case .character: return "Character and Inner Balance"
        case .family: return "Family and Relationships"
        case .health: return "Health and Wellbeing"
        case .career: return "Work and Creating"
        case .finance: return "Finances and Giving"
        case .service: return "Community and Contribution"
        }
    }
    // Former labels remain valid when importing user-edited plan CSV files.
    public var legacyTitles: [String] {
        switch self {
        case .spiritual: return ["Kulluk ve Manevî Hayat", "Worship and Spiritual Life"]
        case .learning: return ["Kur'an, İlim ve Fikrî Gelişim", "Quran, Learning and Intellectual Growth"]
        case .character: return ["Ahlâk, Nefs Terbiyesi ve İç Disiplin", "Character and Inner Discipline"]
        case .family: return ["Aile, Akraba, Dostluk ve Sosyal Hayat", "Family, Friends and Social Life"]
        case .health: return ["Sağlık, Beden ve Yaşam Düzeni", "Health, Body and Daily Rhythm"]
        case .career: return ["Meslek, Yetkinlik, Üretim ve Kariyer", "Profession, Skills and Career"]
        case .finance: return ["Mali Hayat, Helal Kazanç, İnfak ve Hac Hazırlığı", "Finances, Ethical Income, Giving and Hajj"]
        case .service: return ["Hizmet, Toplumsal Fayda ve Miras", "Service, Social Contribution and Legacy"]
        }
    }
    public var symbol: String {
        switch self {
        case .spiritual: return "sparkles"
        case .learning: return "book.closed"
        case .character: return "leaf"
        case .family: return "person.2"
        case .health: return "heart"
        case .career: return "briefcase"
        case .finance: return "banknote"
        case .service: return "hands.sparkles"
        }
    }
}
public enum Recurrence: String, CaseIterable, Codable, Sendable {
    case none, daily, weekly, monthly, yearly, hijriMonthly, hijriYearly
}
public enum OccurrenceStatus: String, CaseIterable, Sendable {
    case planned, partial, completed, skipped, cancelled, moved
}

public struct DaySummary: Equatable, Sendable {
    public let day: String
    public let planned: Int
    public let completed: Int
    public let partial: Int
    public let ratio: Double?
}
public struct Allocation: Equatable, Sendable {
    public var day: String
    public var target: Double
    public var value: Double
}
public struct PlanningEngine: Sendable {
    public let timeZone: TimeZone
    public let hijriOffset: Int
    public let localeIdentifier: String
    public var calendar: Calendar {
        var result = Calendar(identifier: .gregorian)
        result.timeZone = timeZone
        result.locale = Locale(identifier: localeIdentifier)
        result.firstWeekday = 2
        result.minimumDaysInFirstWeek = 4
        return result
    }
    public var hijriCalendar: Calendar {
        var result = Calendar(identifier: .islamicUmmAlQura)
        result.timeZone = timeZone
        result.locale = Locale(identifier: localeIdentifier)
        return result
    }
    public init(timeZone: TimeZone = .current, hijriOffset: Int = 0, localeIdentifier: String = "tr") {
        self.timeZone = timeZone
        self.hijriOffset = hijriOffset
        self.localeIdentifier = localeIdentifier
    }
    public func key(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }
    public func date(_ key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, let d = calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2], hour: 12)), self.key(d) == key else { return nil }
        return d
    }
    public func addingDays(_ count: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: count, to: date)!
    }
    public func days(from start: Date, through end: Date) -> [Date] {
        var cursor = calendar.startOfDay(for: start)
        let limit = calendar.startOfDay(for: end)
        guard cursor <= limit else { return [] }
        var result: [Date] = []
        while cursor <= limit, result.count < 36600 {
            result.append(cursor)
            cursor = addingDays(1, to: cursor)
        }
        return result
    }
    public func isDue(_ task: PlannedTaskRecord, on date: Date, restWeekdays: [Int] = []) -> Bool {
        let day = calendar.startOfDay(for: date), start = calendar.startOfDay(for: task.start)
        guard !task.archived, day >= start else { return false }
        if let end = task.end, day > calendar.startOfDay(for: end) { return false }
        let weekday = calendar.component(.weekday, from: day)
        if task.isHabit && restWeekdays.contains(weekday) { return false }
        guard let recurrence = Recurrence(rawValue: task.recurrence) else { return false }
        switch recurrence {
        case .none: return day == start
        case .daily: return task.weekdays.isEmpty || task.weekdays.contains(weekday)
        case .weekly: return task.weekdays.isEmpty ? weekday == calendar.component(.weekday, from: start) : task.weekdays.contains(weekday)
        case .monthly: return monthMatch(start: start, day: day, calendar: calendar)
        case .yearly: return calendar.component(.month, from: start) == calendar.component(.month, from: day) && monthMatch(start: start, day: day, calendar: calendar)
        case .hijriMonthly, .hijriYearly:
            let shiftedDay = addingDays(hijriOffset, to: day)
            let shiftedStart = addingDays(hijriOffset, to: start)
            return (recurrence == .hijriMonthly || hijriCalendar.component(.month, from: shiftedDay) == hijriCalendar.component(.month, from: shiftedStart)) && monthMatch(start: shiftedStart, day: shiftedDay, calendar: hijriCalendar)
        }
    }
    private func monthMatch(start: Date, day: Date, calendar: Calendar) -> Bool {
        guard let range = calendar.range(of: .day, in: .month, for: day) else { return false }
        return calendar.component(.day, from: day) == min(calendar.component(.day, from: start), range.count)
    }
    public func materialize(_ data: inout BackupDocument, from start: Date, through end: Date) {
        var existing = Set(data.occurrences.map { "\($0.taskID)|\($0.day)" })
        for day in days(from: start, through: end) {
            for task in data.tasks where isDue(task, on: day, restWeekdays: data.preferences.first?.restWeekdays ?? []) {
                let dayKey = key(day), unique = "\(task.id)|\(dayKey)"
                guard existing.insert(unique).inserted else { continue }
                data.occurrences.append(.init(taskID: task.id, day: dayKey, title: task.title, domainID: task.domainID, goalID: task.goalID, target: task.target, unit: task.unit, priority: task.priority))
            }
        }
    }
    public static func setProgress(_ value: Double, occurrence: inout TaskOccurrenceRecord) throws {
        guard value.isFinite, value >= 0, occurrence.target > 0 else { throw PlanError.invalid("validation.progress") }
        guard !["moved", "cancelled", "skipped"].contains(occurrence.status) else { throw PlanError.invalid("validation.closed") }
        occurrence.value = min(value, occurrence.target)
        occurrence.status = occurrence.value >= occurrence.target ? "completed" : occurrence.value > 0 ? "partial" : "planned"
    }
    public func move(_ id: String, to destination: Date, in data: inout BackupDocument) throws {
        guard let index = data.occurrences.firstIndex(where: { $0.id == id }) else { throw PlanError.invalid("validation.missing") }
        let source = data.occurrences[index], day = key(destination)
        guard source.status == "planned" || source.status == "partial" else { throw PlanError.invalid("validation.closed") }
        guard !data.occurrences.contains(where: { $0.taskID == source.taskID && $0.day == day }) else { throw PlanError.invalid("validation.duplicateDay") }
        var copy = source
        copy.id = UUID().uuidString
        copy.day = day
        copy.originalDay = source.day
        data.occurrences[index].status = "moved"
        data.occurrences.append(copy)
    }
    public func redistributionProposal(_ occurrence: TaskOccurrenceRecord, from start: Date, through end: Date, in data: BackupDocument) throws -> [Allocation] {
        let dates = days(from: start, through: end)
        guard !dates.isEmpty, dates.count <= 90, ["planned", "partial"].contains(occurrence.status), occurrence.value < occurrence.target else { throw PlanError.invalid("validation.data") }
        let keys = dates.map(key)
        guard !data.occurrences.contains(where: { $0.taskID == occurrence.taskID && keys.contains($0.day) }) else { throw PlanError.invalid("validation.duplicateDay") }
        let proposal = try allocations(total: occurrence.target - occurrence.value, unit: occurrence.unit, from: start, through: end)
        return proposal.enumerated().map { index, item in
            Allocation(day: item.day, target: item.amount + (index == 0 ? occurrence.value : 0), value: index == 0 ? occurrence.value : 0)
        }
    }
    public func redistribute(_ id: String, from start: Date, through end: Date, in data: inout BackupDocument) throws {
        guard let index = data.occurrences.firstIndex(where: { $0.id == id }) else { throw PlanError.invalid("validation.missing") }
        let source = data.occurrences[index]
        let proposal = try redistributionProposal(source, from: start, through: end, in: data)
        data.occurrences[index].status = "moved"
        for allocation in proposal {
            var record = source
            record.id = UUID().uuidString
            record.originalDay = source.day
            record.day = allocation.day
            record.target = allocation.target
            record.value = allocation.value
            record.status = allocation.value > 0 ? "partial" : "planned"
            data.occurrences.append(record)
        }
    }
    public func summary(_ data: BackupDocument, on date: Date, domainID: String? = nil) -> DaySummary {
        let items = data.occurrences.filter { $0.day == key(date) && (domainID == nil || $0.domainID == domainID) && !["skipped", "cancelled", "moved"].contains($0.status) }
        let completed = items.filter { $0.value >= $0.target }.count
        let partial = items.filter { $0.value > 0 && $0.value < $0.target }.count
        return .init(day: key(date), planned: items.count, completed: completed, partial: partial, ratio: items.isEmpty ? nil : Double(completed) / Double(items.count))
    }
    public func goalValue(_ goalID: String, in data: BackupDocument) -> Double {
        contributions(goalID, in: data).total
    }
    public func remainingPerDay(total: Double, completed: Double, start: Date, end: Date, now: Date) -> Double {
        guard total > 0, total.isFinite, completed.isFinite else { return 0 }
        let lower = max(calendar.startOfDay(for: now), calendar.startOfDay(for: start))
        let count = days(from: lower, through: end).count
        return count == 0 ? max(0, total - completed) : ceil(max(0, total - completed) / Double(count))
    }
    public func nextReview(_ item: MemorizationItemRecord, reviews: [MemorizationReviewRecord]) -> Date? {
        let history = reviews.filter { $0.itemID == item.id }.sorted { $0.date < $1.date }
        guard let last = history.last, !item.intervals.isEmpty else { return nil }
        let index = min(history.count - 1, item.intervals.count - 1)
        return addingDays(item.intervals[index], to: last.date)
    }
    public func streak(taskID: String, data: BackupDocument, through date: Date) -> Int {
        guard let task = data.tasks.first(where: { $0.id == taskID }) else { return 0 }
        var cursor = calendar.startOfDay(for: date), result = 0
        // Today may still be in progress; start at the previous due day in that case.
        if data.occurrences.first(where: { $0.taskID == taskID && $0.day == key(cursor) })?.status != "completed" { cursor = addingDays(-1, to: cursor) }
        while cursor >= calendar.startOfDay(for: task.start) {
            if isDue(task, on: cursor, restWeekdays: data.preferences.first?.restWeekdays ?? []) {
                let record = data.occurrences.first { $0.taskID == taskID && $0.day == key(cursor) }
                if record?.status == "skipped" { cursor = addingDays(-1, to: cursor); continue }
                guard record?.status == "completed" else { break }
                result += 1
            }
            cursor = addingDays(-1, to: cursor)
        }
        return result
    }
}

public extension BackupDocument {
    static func fresh() -> BackupDocument {
        var data = BackupDocument()
        data.preferences = [.init(id: "preferences")]
        data.domains = LifeArea.allCases.enumerated().map { .init(id: $0.element.rawValue, key: $0.element.rawValue, rank: $0.offset) }
        return data
    }
    mutating func archiveTask(_ id: String) {
        guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[i].archived = true
    }
    mutating func deleteGoal(_ id: String) {
        goals.removeAll { $0.id == id }
        for i in goals.indices where goals[i].parentID == id { goals[i].parentID = nil }
        for i in tasks.indices where tasks[i].goalID == id { tasks[i].goalID = nil }
        for i in occurrences.indices where occurrences[i].goalID == id { occurrences[i].goalID = nil }
        for i in projects.indices where projects[i].goalID == id { projects[i].goalID = nil }
        goalProgress.removeAll { $0.goalID == id }
        milestones.removeAll { $0.goalID == id }
    }
    mutating func addStarterTemplates(on date: Date, engine: PlanningEngine) {
        // Explicit opt-in only; never generate completion history.
        let templates: [(String, String, Double, String)] = [
            ("template.quran", "learning", 6, "pages"), ("template.movement", "health", 30, "minutes"),
            ("template.family", "family", 1, "count"), ("template.evrad", "spiritual", 1, "count"),
            ("template.reflection", "character", 1, "count"), ("template.skill", "career", 20, "minutes"),
            ("template.saving", "finance", 1, "count"), ("template.service", "service", 1, "count")]
        for (title, area, target, unit) in templates where !tasks.contains(where: { $0.id == "starter:\(title)" || $0.title == title }) {
            tasks.append(.init(id: "starter:\(title)", title: title, domainID: area, start: date, recurrence: "daily", target: target, unit: unit, isHabit: true))
        }
        engine.materialize(&self, from: date, through: date)
    }
}

extension PlanningEngine {
    public func upcomingEvents(_ events: [CalendarEventRecord], after now: Date, horizonDays: Int = 366) -> [(event: CalendarEventRecord, next: Date)] {
        events.compactMap { event in
            let task = PlannedTaskRecord(title: event.title, start: event.date, recurrence: event.recurrence)
            let time = calendar.dateComponents([.hour, .minute], from: event.date)
            for day in days(from: now, through: addingDays(min(366, max(0, horizonDays)), to: now)) where isDue(task, on: day) {
                if let next = calendar.date(bySettingHour: time.hour ?? 0, minute: time.minute ?? 0, second: 0, of: day), next >= now { return (event, next) }
            }
            return nil
        }.sorted { $0.next < $1.next }
    }
}
