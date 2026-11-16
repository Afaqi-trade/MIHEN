import Foundation

public struct SourceEvent: Identifiable, Equatable, Sendable {
    public let kind: String
    public let sourceID: String
    public let date: Date
    public let domainID: String
    public let unit: String
    public let amount: Double
    public let title: String
    public var id: String { kind + ":" + sourceID }
}
extension BackupDocument {
    public func sourceEvents(engine: PlanningEngine) -> [SourceEvent] {
        var result: [SourceEvent] = []
        for row in readings {
            if let parent = khatms.first(where: { $0.id == row.khatmID }) {
                result.append(.init(kind:"reading",sourceID:row.id,date:row.date,domainID:"learning",unit:"pages",amount:Double(row.pages),title:parent.title))
            }
        }
        for row in memorizationReviews {
            if let parent = memorization.first(where: { $0.id == row.itemID }) {
                result.append(.init(kind:"review",sourceID:row.id,date:row.date,domainID:"learning",unit:"count",amount:1,title:parent.title))
            }
        }
        for row in dhikr {
            if let date=engine.date(row.day) { result.append(.init(kind:"dhikr",sourceID:row.id,date:date,domainID:"spiritual",unit:"count",amount:Double(row.value),title:row.title)) }
        }
        for row in fasts {
            result.append(.init(kind:"fast",sourceID:row.id,date:row.date,domainID:"spiritual",unit:"days",amount:row.status == "completed" ? 1 : 0,title:row.title))
        }
        for row in effectiveActivities(engine:engine) where !["qadaDebt","qadaDone"].contains(row.kind) {
            result.append(.init(kind:"activity",sourceID:row.id,date:row.date,domainID:row.domainID,unit:row.unit,amount:row.amount,title:row.note.isEmpty ? "activity."+row.kind : row.note))
        }
        return result
    }
    public mutating func connectSource(_ eventID: String, to occurrenceID: String, engine: PlanningEngine) throws {
        var next=self
        guard let event=sourceEvents(engine:engine).first(where: { $0.id == eventID }), event.amount > 0,
              let row=occurrences.first(where: { $0.id == occurrenceID }),
              ["planned","partial","completed"].contains(row.status), row.domainID == event.domainID,
              row.unit == event.unit, row.day == engine.key(event.date),
              !sourceLinks.contains(where: { $0.occurrenceID == occurrenceID || ($0.sourceKind == event.kind && $0.sourceID == event.sourceID) }) else { throw PlanError.invalid("source.incompatible") }
        next.sourceLinks.append(.init(sourceKind:event.kind,sourceID:event.sourceID,occurrenceID:row.id,previousValue:row.value))
        try next.reconcileSources(engine:engine)
        try BackupCodec.validate(next);self=next
    }
    public mutating func disconnectSource(_ id: String, engine: PlanningEngine) throws {
        guard let link=sourceLinks.first(where: { $0.id == id }) else { throw PlanError.invalid("validation.missing") }
        var next=self
        if let i=next.occurrences.firstIndex(where: { $0.id == link.occurrenceID }) {
            try PlanningEngine.setProgress(link.previousValue,occurrence:&next.occurrences[i])
        }
        next.sourceLinks.removeAll { $0.id == id }
        try BackupCodec.validate(next);self=next
    }
    /// Only an explicitly linked source may update its matching occurrence.
    /// Deleting a source restores the independent amount saved before connection.
    public mutating func reconcileSources(engine: PlanningEngine) throws {
        let events=Dictionary(uniqueKeysWithValues:sourceEvents(engine:engine).map { ($0.id,$0) })
        var removed=Set<String>()
        for link in sourceLinks {
            guard let i=occurrences.firstIndex(where: { $0.id == link.occurrenceID }) else { removed.insert(link.id);continue }
            guard let event=events[link.sourceKind+":"+link.sourceID] else {
                try PlanningEngine.setProgress(link.previousValue,occurrence:&occurrences[i]);removed.insert(link.id);continue
            }
            let row=occurrences[i]
            guard row.domainID == event.domainID, row.unit == event.unit, row.day == engine.key(event.date),
                  ["planned","partial","completed"].contains(row.status) else { throw PlanError.invalid("source.disconnectFirst") }
            try PlanningEngine.setProgress(min(row.target,event.amount),occurrence:&occurrences[i])
        }
        sourceLinks.removeAll { removed.contains($0.id) }
        let taskIDs=Set(tasks.map(\.id)), occurrenceIDs=Set(occurrences.map(\.id)), activityIDs=Set(activities.map(\.id)), routineIDs=Set(routines.map(\.id)), goalIDs=Set(goals.map(\.id))
        taskEstimates.removeAll { !taskIDs.contains($0.taskID) }
        occurrenceEstimates.removeAll { !occurrenceIDs.contains($0.occurrenceID) }
        activityAnnotations.removeAll { !activityIDs.contains($0.activityID) }
        routineSchedules.removeAll { !routineIDs.contains($0.routineID) }
        routineSessions.removeAll { !routineIDs.contains($0.routineID) }
        goalSupports.removeAll { !goalIDs.contains($0.goalID) || !taskIDs.contains($0.taskID) }
    }
    public func option(_ key: String, fallback: String = "") -> String { options.first { $0.key == key }?.value ?? fallback }
    public mutating func setOption(_ key: String, value: String) {
        options.removeAll { $0.key == key };options.append(.init(key:key,value:value))
    }
}
