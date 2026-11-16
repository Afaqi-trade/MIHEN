import Foundation

public struct TemplateDayPreview: Identifiable, Sendable {
    public let day: String
    public let items: [StarterTemplate]
    public var id: String { day }
}
extension PlanningEngine {
    public func starterPreview(_ selected: Set<String>, from date: Date, in data: BackupDocument) -> [TemplateDayPreview] {
        let items=StarterTemplate.choices.filter { item in selected.contains(item.id) && !data.tasks.contains(where: { $0.id == "starter:\(item.id)" || $0.title == item.id }) }
        return (0..<7).map { .init(day:key(addingDays($0,to:date)),items:items) }
    }
}
public struct GuidedTemplate: Identifiable, Sendable {
    public let id: String
    public let minutes: Double
    public let weekdays: [Int]
    public var titleKey: String { "example."+id+".goal" }
    public var taskKey: String { "example."+id+".task" }
    public static let choices: [GuidedTemplate] = [
        .init(id:"learning",minutes:30,weekdays:[2,5]),.init(id:"career",minutes:30,weekdays:[3,6]),
        .init(id:"family",minutes:30,weekdays:[1]),.init(id:"service",minutes:60,weekdays:[7]),
        .init(id:"health",minutes:20,weekdays:[2,4,6]),.init(id:"finance",minutes:20,weekdays:[1]),
        .init(id:"character",minutes:10,weekdays:[3,6]),.init(id:"spiritual",minutes:15,weekdays:[2,4,7])]
}
extension BackupDocument {
    /// Explicitly selected, editable plan only. Different units are linked as support, never converted.
    public mutating func applyGuidedTemplate(_ template: GuidedTemplate, from start: Date, goalTitle: String, taskTitle: String, milestoneTitle: String, engine: PlanningEngine) throws {
        let prefix="guided:"+template.id
        guard !goals.contains(where: { $0.id == prefix }), !tasks.contains(where: { $0.id == prefix+":task" }) else { return }
        var next=self
        let end=engine.addingDays(89,to:start)
        next.goals.append(.init(id:prefix,title:goalTitle,domainIDs:[template.id],horizon:"quarter",start:start,end:end,target:1,unit:"count"))
        next.milestones.append(.init(goalID:prefix,title:milestoneTitle,due:engine.addingDays(29,to:start)))
        next.tasks.append(.init(id:prefix+":task",title:taskTitle,domainID:template.id,start:start,end:end,recurrence:"weekly",target:template.minutes,unit:"minutes",isHabit:true,weekdays:template.weekdays))
        next.goalSupports.append(.init(goalID:prefix,taskID:prefix+":task"))
        engine.materialize(&next,from:start,through:start)
        try BackupCodec.validate(next);self=next
    }
}
