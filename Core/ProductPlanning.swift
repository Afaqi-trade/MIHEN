import Foundation

public struct PlannedAllocation: Equatable, Sendable {
    public let day: String
    public let amount: Double
}
public struct GoalContributions: Equatable, Sendable {
    public let manual: Double
    public let tasks: Double
    public var total: Double { manual + tasks }
}
extension PlanningEngine {
    public func contributions(_ goalID: String, in data: BackupDocument, interval: DateInterval? = nil) -> GoalContributions {
        let unit = data.goals.first { $0.id == goalID }?.unit
        let manual = data.goalProgress.filter { row in
            row.goalID == goalID && (interval.map { row.date >= $0.start && row.date < $0.end } ?? true)
        }.reduce(0) { $0 + $1.amount }
        let tasks = data.occurrences.filter {
            $0.goalID == goalID && $0.status != "moved" && $0.unit == unit
        }.filter { row in
            guard let interval else { return true }
            return row.day >= key(interval.start) && row.day < key(interval.end)
        }.reduce(0) { $0 + $1.value }
        return .init(manual: manual, tasks: tasks)
    }
    /// Uses integer ticks, so displayed allocations and stored totals agree.
    /// Discrete units never create fractional tasks. Existing snapshots are untouched.
    public func allocations(total: Double, unit: String, from start: Date, through end: Date, weekdays: Set<Int> = Set(1...7)) throws -> [PlannedAllocation] {
        let lower = calendar.startOfDay(for: start), upper = calendar.startOfDay(for: end)
        guard total.isFinite, total > 0, total <= 1_000_000_000,
              let span = calendar.dateComponents([.day], from: lower, to: upper).day, (0..<366).contains(span),
              !weekdays.isEmpty, weekdays.isSubset(of: Set(1...7)) else { throw PlanError.invalid("planning.invalid") }
        let discrete = ["count", "books", "pages"].contains(unit)
        let scale = discrete ? 1.0 : 100.0
        let scaled = total * scale
        guard abs(scaled - scaled.rounded()) < 0.00001 else { throw PlanError.invalid(discrete ? "planning.whole" : "planning.precision") }
        let ticks = Int(scaled.rounded())
        let dates = days(from: lower, through: upper).filter { weekdays.contains(calendar.component(.weekday, from: $0)) }
        guard ticks > 0, !dates.isEmpty else { throw PlanError.invalid("planning.invalid") }
        let used = min(ticks, dates.count), base = ticks / used, remainder = ticks % used
        return (0..<used).map { index in
            // Spread sparse targets across the entire selected interval.
            let offset = used == 1 ? 0 : index * (dates.count - 1) / (used - 1)
            let extra = ((index + 1) * remainder / used) - (index * remainder / used)
            return .init(day: key(dates[offset]), amount: Double(base + extra) / scale)
        }
    }
    public func goalAllocations(_ goalID: String, in data: BackupDocument, from start: Date, through end: Date, weekdays: Set<Int>) throws -> [PlannedAllocation] {
        guard let goal = data.goals.first(where: { $0.id == goalID }), !goal.archived,
              !data.tasks.contains(where: { $0.goalID == goalID && !$0.archived }) else { throw PlanError.invalid("planning.linked") }
        return try allocations(total: max(0, goal.target - goalValue(goalID, in: data)), unit: goal.unit, from: start, through: end, weekdays: weekdays)
    }
    public func applyGoalPlan(_ goalID: String, from start: Date, through end: Date, weekdays: Set<Int>, in data: inout BackupDocument) throws {
        let proposal = try goalAllocations(goalID, in: data, from: start, through: end, weekdays: weekdays)
        guard let goal = data.goals.first(where: { $0.id == goalID }) else { throw PlanError.invalid("validation.missing") }
        for item in proposal {
            guard let day = date(item.day) else { throw PlanError.invalid("validation.data") }
            data.tasks.append(.init(title: goal.title, domainID: goal.domainIDs.first ?? "learning", goalID: goalID, start: day, end: day, target: item.amount, unit: goal.unit, priority: goal.priority))
        }
        materialize(&data, from: start, through: end)
    }
}

public struct StarterTemplate: Identifiable, Sendable {
    public let id: String
    public let area: String
    public let target: Double
    public let unit: String
    public static let choices: [StarterTemplate] = [
        .init(id: "template.quran", area: "learning", target: 6, unit: "pages"),
        .init(id: "template.movement", area: "health", target: 30, unit: "minutes"),
        .init(id: "template.family", area: "family", target: 1, unit: "count"),
        .init(id: "template.evrad", area: "spiritual", target: 1, unit: "count"),
        .init(id: "template.reflection", area: "character", target: 1, unit: "count"),
        .init(id: "template.skill", area: "career", target: 20, unit: "minutes"),
        .init(id: "template.saving", area: "finance", target: 1, unit: "count"),
        .init(id: "template.service", area: "service", target: 1, unit: "count")]
}
extension BackupDocument {
    public mutating func addSelectedTemplates(_ selected: Set<String>, on date: Date, engine: PlanningEngine) {
        for item in StarterTemplate.choices where selected.contains(item.id) && !tasks.contains(where: { $0.id == "starter:\(item.id)" || $0.title == item.id }) {
            tasks.append(.init(id: "starter:\(item.id)", title: item.id, domainID: item.area, start: date, recurrence: "daily", target: item.target, unit: item.unit, isHabit: true))
        }
        engine.materialize(&self, from: date, through: date)
    }
}

extension PlanningEngine {
    public func archiveFutureGoalPlan(_ goalID: String, on now: Date, in data: inout BackupDocument) {
        let members = data.tasks.filter { $0.goalID == goalID && !$0.archived }
        for task in members { materialize(&data, from: max(task.start, addingDays(-366, to: now)), through: now) }
        let ids = Set(members.map(\.id))
        for i in data.tasks.indices where ids.contains(data.tasks[i].id) { data.tasks[i].archived = true }
        for i in data.occurrences.indices where ids.contains(data.occurrences[i].taskID) && data.occurrences[i].day >= key(now) && ["planned", "partial"].contains(data.occurrences[i].status) {
            data.occurrences[i].status = "cancelled"
        }
    }
}

extension BackupDocument {
    /// Imported daily active energy supersedes the manual subtotal for that day,
    /// retaining manual rows so removing the imported snapshot restores them.
    public func effectiveActivities(engine: PlanningEngine) -> [DomainActivityRecord] {
        let importedDays = Set(activities.filter { $0.kind == "energyBurned" && $0.id.hasPrefix("health.energy:") }.map { engine.key($0.date) })
        return activities.filter { $0.kind != "energyBurned" || $0.id.hasPrefix("health.energy:") || !importedDays.contains(engine.key($0.date)) }
    }
    public mutating func recordHealthSummary(on date: Date, steps: Double?, energy: Double?, engine: PlanningEngine) throws {
        var candidate = self
        for (kind, value, prefix, unit) in [("steps",steps,"health.steps:","count"),("energyBurned",energy,"health.energy:","kcal")] {
            guard let value else { continue }
            guard value.isFinite, value >= 0, value <= 1e12 else { throw PlanError.invalid("validation.progress") }
            let id = prefix + engine.key(date)
            let record = DomainActivityRecord(id:id,domainID:"health",date:date,kind:kind,amount:value,unit:unit)
            if let i = candidate.activities.firstIndex(where: { $0.id == id }) { candidate.activities[i] = record } else { candidate.activities.append(record) }
        }
        try BackupCodec.validate(candidate); self = candidate
    }
}
