import Foundation

public struct DayWorkload: Identifiable, Equatable, Sendable {
    public let id: String
    public let minutes: Double
    public let unknown: Int
    public let capacity: Int?
    public var excess: Double { capacity.map { max(0,minutes-Double($0)) } ?? 0 }
}
extension PlanningEngine {
    public func workload(_ data: BackupDocument, on day: Date) -> DayWorkload {
        let k=key(day)
        let estimates=Dictionary(uniqueKeysWithValues:data.occurrenceEstimates.map { ($0.occurrenceID,$0.minutes) })
        let rows=data.occurrences.filter { $0.day == k && !["skipped","cancelled","moved"].contains($0.status) }
        var minutes=0.0,unknown=0
        for row in rows {
            if let duration=estimates[row.id] { minutes += duration }
            else if row.unit == "minutes" { minutes += row.target }
            else { unknown += 1 }
        }
        return .init(id:k,minutes:minutes,unknown:unknown,capacity:data.capacities.first { $0.weekday == calendar.component(.weekday,from:day) }?.minutes)
    }
    public func capacityAllocations(total: Double, unit: String, minutesPerUnit: Double, from start: Date, through end: Date, weekdays: Set<Int>, in data: BackupDocument) throws -> [PlannedAllocation] {
        // Reuse the precision/range validation of the standard allocator.
        _ = try allocations(total:total,unit:unit,from:start,through:end,weekdays:weekdays)
        guard data.capacities.count == 7, minutesPerUnit.isFinite, minutesPerUnit > 0, minutesPerUnit <= 1440 else { throw PlanError.invalid("capacity.required") }
        let scale=["count","books","pages"].contains(unit) ? 1.0 : 100.0
        let ticks=Int((total*scale).rounded())
        let eligible=days(from:start,through:end).filter { weekdays.contains(calendar.component(.weekday,from:$0)) }
        guard !eligible.contains(where: { workload(data,on:$0).unknown > 0 }) else { throw PlanError.invalid("capacity.unknown") }
        let limits=eligible.map { day -> Int in
            let load=workload(data,on:day)
            let free=max(0,Double(load.capacity ?? 0)-load.minutes)
            return Int(min(1e12,floor(free / minutesPerUnit * scale + 1e-8)))
        }
        let totalCapacity=limits.reduce(Int64(0)) { $0+Int64($1) }
        guard totalCapacity >= Int64(ticks), totalCapacity > 0 else { throw PlanError.invalid("capacity.insufficient") }
        var assigned=limits.map { Int(floor(Double(ticks)*Double($0)/Double(totalCapacity))) }
        var left=ticks-assigned.reduce(0,+)
        let order=limits.indices.sorted { a,b in
            let ar=Double(ticks)*Double(limits[a])/Double(totalCapacity)-Double(assigned[a])
            let br=Double(ticks)*Double(limits[b])/Double(totalCapacity)-Double(assigned[b])
            return abs(ar-br)<1e-10 ? a<b : ar>br
        }
        for i in order where left > 0 && assigned[i] < limits[i] { assigned[i] += 1;left -= 1 }
        guard left == 0 else { throw PlanError.invalid("capacity.insufficient") }
        return eligible.indices.compactMap { assigned[$0] > 0 ? .init(day:key(eligible[$0]),amount:Double(assigned[$0])/scale) : nil }
    }
    public func applyCapacityGoalPlan(_ goalID: String, from start: Date, through end: Date, weekdays: Set<Int>, minutesPerUnit: Double, in data: inout BackupDocument) throws {
        var next=data
        guard let goal=data.goals.first(where: { $0.id == goalID }), !goal.archived,
              !data.tasks.contains(where: { $0.goalID == goalID && !$0.archived }) else { throw PlanError.invalid("planning.linked") }
        let proposal=try capacityAllocations(total:max(0,goal.target-goalValue(goalID,in:data)),unit:goal.unit,minutesPerUnit:minutesPerUnit,from:start,through:end,weekdays:weekdays,in:data)
        for entry in proposal {
            guard let date=date(entry.day) else { throw PlanError.invalid("validation.data") }
            let task=PlannedTaskRecord(title:goal.title,domainID:goal.domainIDs.first ?? "learning",goalID:goalID,start:date,end:date,target:entry.amount,unit:goal.unit,priority:goal.priority)
            next.tasks.append(task)
            next.taskEstimates.append(.init(taskID:task.id,minutes:entry.amount*minutesPerUnit))
        }
        if let i=next.goals.firstIndex(where: { $0.id == goalID }) { next.goals[i].end=end }
        materialize(&next,from:start,through:end)
        next.captureEstimates(engine:self,on:start)
        try BackupCodec.validate(next);data=next
    }
}
extension BackupDocument {
    public mutating func captureEstimates(engine: PlanningEngine, on now: Date) {
        let lower=engine.key(now), existing=Set(occurrenceEstimates.map(\.occurrenceID))
        let estimates=Dictionary(uniqueKeysWithValues:taskEstimates.map { ($0.taskID,$0.minutes) })
        for row in occurrences where row.day >= lower && row.status == "planned" && !existing.contains(row.id) {
            if let minutes=estimates[row.taskID] { occurrenceEstimates.append(.init(occurrenceID:row.id,minutes:minutes)) }
        }
    }
    public mutating func setTaskEstimate(_ taskID: String, minutes: Double?, engine: PlanningEngine, on now: Date) throws {
        guard tasks.contains(where: { $0.id == taskID }) else { throw PlanError.invalid("validation.missing") }
        var next=self;next.taskEstimates.removeAll { $0.taskID == taskID }
        if let minutes {
            guard minutes.isFinite, minutes > 0, minutes <= 1440 else { throw PlanError.invalid("capacity.invalid") }
            next.taskEstimates.append(.init(taskID:taskID,minutes:minutes))
        }
        let ids=Set(occurrences.filter { $0.taskID == taskID && $0.day >= engine.key(now) && $0.status == "planned" }.map(\.id))
        next.occurrenceEstimates.removeAll { ids.contains($0.occurrenceID) }
        next.captureEstimates(engine:engine,on:now)
        try BackupCodec.validate(next);self=next
    }
    public mutating func setWeeklyFocus(week: Date, items: [(kind:String,id:String)], engine: PlanningEngine) throws {
        guard items.count <= 3, Set(items.map { $0.kind+":"+$0.id }).count == items.count,
              let interval=engine.calendar.dateInterval(of:.weekOfYear,for:week) else { throw PlanError.invalid("validation.data") }
        let day=engine.key(interval.start);var next=self
        next.weeklyFocuses.removeAll { $0.week == day }
        for (rank,item) in items.enumerated() {
            let title: String?
            if item.kind == "goal" { title=goals.first { $0.id == item.id && !$0.archived }?.title }
            else if item.kind == "task" { title=tasks.first { $0.id == item.id && !$0.archived }?.title }
            else { title=nil }
            guard let title else { throw PlanError.invalid("validation.missing") }
            next.weeklyFocuses.append(.init(week:day,kind:item.kind,referenceID:item.id,title:title,rank:rank))
        }
        try BackupCodec.validate(next);self=next
    }
}
