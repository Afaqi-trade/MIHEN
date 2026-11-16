import Foundation

extension BackupDocument {
    public var waterShortcuts: [Int] { option("water.quick",fallback:"250,500").split(separator:",").compactMap { Int($0) } }
    public func nutritionTotal(_ kind: String, on day: Date, engine: PlanningEngine, planned: Bool = false) -> Double {
        if planned { return nutritionPlans.filter { $0.kind == kind && engine.key($0.date) == engine.key(day) }.reduce(0) { $0+$1.amount } }
        return effectiveActivities(engine:engine).filter { $0.kind == kind && engine.key($0.date) == engine.key(day) }.reduce(0) { $0+$1.amount }
    }
    @discardableResult public mutating func saveNutrition(id: String? = nil, date: Date, kind: String, amount: Double, meal: String, title: String, note: String, engine: PlanningEngine, recordedAt: Date = Date()) throws -> String {
        guard ["food","water","energyBurned"].contains(kind),amount.isFinite,amount > 0,amount <= 1e9 else { throw PlanError.invalid("validation.progress") }
        var next=self
        let recordID=id ?? UUID().uuidString
        guard !recordID.hasPrefix("health.") else { throw PlanError.invalid("nutrition.health.readOnly") }
        if let id { guard activities.contains(where: { $0.id == id && $0.domainID == "health" && ["food","water","energyBurned"].contains($0.kind) }) else { throw PlanError.invalid("validation.missing") } }
        let row=DomainActivityRecord(id:recordID,domainID:"health",date:date,kind:kind,amount:amount,unit:kind == "water" ? "ml" : "kcal",note:note)
        if let i=next.activities.firstIndex(where: { $0.id == recordID }) { next.activities[i]=row } else { next.activities.append(row) }
        next.activityAnnotations.removeAll { $0.activityID == recordID }
        next.activityAnnotations.append(.init(activityID:recordID,meal:meal,title:title,lastUsed:recordedAt))
        try next.reconcileSources(engine:engine);try BackupCodec.validate(next);self=next;return recordID
    }
    public mutating func saveNutritionPlan(_ record: NutritionPlanRecord) throws {
        var next=self
        if let i=next.nutritionPlans.firstIndex(where: { $0.id == record.id }) { next.nutritionPlans[i]=record } else { next.nutritionPlans.append(record) }
        try BackupCodec.validate(next);self=next
    }
}
