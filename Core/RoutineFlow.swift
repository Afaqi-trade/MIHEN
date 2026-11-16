import Foundation

extension PlanningEngine {
    public func routineIsPaused(_ id: String, in data: BackupDocument) -> Bool {
        if let schedule=data.routineSchedules.first(where: { $0.routineID == id }) { return schedule.paused }
        let ids=Set(data.routineItems.filter { $0.routineID == id }.map(\.taskID))
        let tasks=data.tasks.filter { ids.contains($0.id) }
        return !tasks.isEmpty && tasks.allSatisfy(\.archived)
    }
    public func routineIsAvailable(_ id: String, on day: Date, in data: BackupDocument) -> Bool {
        guard !routineIsPaused(id,in:data) else { return false }
        if let schedule=data.routineSchedules.first(where: { $0.routineID == id }), !schedule.weekdays.contains(calendar.component(.weekday,from:day)) { return false }
        let ids=Set(data.routineItems.filter { $0.routineID == id }.map(\.taskID))
        return data.tasks.contains { ids.contains($0.id) && isDue($0,on:day,restWeekdays:data.preferences[0].restWeekdays) }
    }
    public func pauseRoutine(_ id: String, paused: Bool, in data: inout BackupDocument) throws {
        guard data.routines.contains(where: { $0.id == id }) else { throw PlanError.invalid("validation.missing") }
        if let i=data.routineSchedules.firstIndex(where: { $0.routineID == id }) { data.routineSchedules[i].paused=paused }
        else { data.routineSchedules.append(.init(routineID:id,paused:paused)) }
        // Group scheduling never archives a shared task or edits occurrences.
    }
    public func beginRoutine(_ id: String, on day: Date, in data: inout BackupDocument) throws -> String {
        let dayKey=key(day)
        guard routineIsAvailable(id,on:day,in:data) else { throw PlanError.invalid("routine.unavailable") }
        if let previous=data.routineSessions.first(where: { $0.routineID == id && $0.day == dayKey }) { return previous.id }
        var next=data;materialize(&next,from:day,through:day)
        let eligible=Set(next.occurrences.filter { $0.day == dayKey && ["planned","partial","completed"].contains($0.status) }.map(\.taskID))
        let tasks=next.routineItems.filter { $0.routineID == id && eligible.contains($0.taskID) }.sorted { $0.rank < $1.rank }.map(\.taskID)
        guard !tasks.isEmpty else { throw PlanError.invalid("routine.unavailable") }
        let session=RoutineSessionRecord(routineID:id,day:dayKey,taskIDs:tasks)
        next.routineSessions.append(session);try BackupCodec.validate(next);data=next;return session.id
    }
}
