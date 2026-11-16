import Foundation

extension BackupDocument {
    public func validateRoadmap() throws {
        func check(_ value: Bool) throws { if !value { throw PlanError.invalid("validation.data") } }
        func distinct(_ values: [String]) throws { try check(Set(values).count == values.count) }
        let tasks=Set(tasks.map(\.id)), goals=Set(goals.map(\.id)), routines=Set(routines.map(\.id)), activities=Set(activities.map(\.id))
        let engine=PlanningEngine(timeZone:TimeZone(identifier:preferences[0].timeZoneID)!)
        let events=Dictionary(uniqueKeysWithValues:sourceEvents(engine:engine).map { ($0.id,$0) })
        try distinct(sourceLinks.map { $0.sourceKind+":"+$0.sourceID });try distinct(sourceLinks.map(\.occurrenceID))
        for link in sourceLinks {
            guard let event=events[link.sourceKind+":"+link.sourceID], let row=occurrences.first(where: { $0.id == link.occurrenceID }) else { throw PlanError.invalid("validation.missing") }
            try check(row.unit == event.unit && row.domainID == event.domainID && row.day == link.day && event.date == link.sourceDate)
            try check(link.previousValue.isFinite && link.previousValue >= 0 && link.previousValue <= row.target)
            try check(["planned","partial","completed"].contains(row.status) && row.value == min(row.target,event.amount))
        }
        try check(capacities.isEmpty || capacities.count == 7);try distinct(capacities.map { String($0.weekday) })
        for row in capacities { try check((1...7).contains(row.weekday) && (0...1440).contains(row.minutes)) }
        try distinct(taskEstimates.map(\.taskID));try distinct(occurrenceEstimates.map(\.occurrenceID))
        for row in taskEstimates { try check(tasks.contains(row.taskID) && row.minutes.isFinite && row.minutes > 0 && row.minutes <= 1440) }
        for row in occurrenceEstimates { try check(occurrences.contains { $0.id == row.occurrenceID } && row.minutes.isFinite && row.minutes > 0 && row.minutes <= 1440) }
        try distinct(goalSupports.map { $0.goalID+":"+$0.taskID })
        for row in goalSupports { try check(tasks.contains(row.taskID) && goals.contains(row.goalID)) }
        try distinct(weeklyFocuses.map { $0.week+":"+String($0.rank) })
        for row in weeklyFocuses { try check(engine.date(row.week) != nil && ["goal","task"].contains(row.kind) && !row.referenceID.isEmpty && row.referenceID.count <= 150 && !row.title.isEmpty && row.title.count <= 500 && (0..<3).contains(row.rank)) }
        try distinct(routineSchedules.map(\.routineID))
        for row in routineSchedules { try check(routines.contains(row.routineID) && !row.weekdays.isEmpty && Set(row.weekdays).count == row.weekdays.count && row.weekdays.allSatisfy { (1...7).contains($0) }) }
        try distinct(routineSessions.map { $0.routineID+":"+$0.day })
        for row in routineSessions { try check(routines.contains(row.routineID) && engine.date(row.day) != nil && row.position >= 0 && row.position <= row.taskIDs.count && row.taskIDs.count <= 1000 && Set(row.taskIDs).count == row.taskIDs.count) }
        try distinct(activityAnnotations.map(\.activityID))
        let meals=["breakfast","lunch","dinner","snack","other"]
        for row in activityAnnotations { try check(activities.contains(row.activityID) && meals.contains(row.meal) && row.title.count <= 200 && row.lastUsed.timeIntervalSince1970.isFinite) }
        for row in nutritionPlans { try check(["food","water","energyBurned"].contains(row.kind) && row.unit == (row.kind == "water" ? "ml" : "kcal") && row.amount.isFinite && row.amount > 0 && row.amount <= 1e9 && meals.contains(row.meal) && row.title.count <= 200 && row.date.timeIntervalSince1970.isFinite) }
        try distinct(reviewResponses.map(\.journalID))
        for row in reviewResponses { try check(journals.contains { $0.id == row.journalID && $0.kind != "note" } && [row.well,row.adjust,row.next].allSatisfy { $0.count <= 10000 }) }
        try distinct(options.map(\.key))
        for row in options {
            switch row.key {
            case "water.quick":
                let values=row.value.split(separator:",").compactMap { Int($0) }
                try check(!values.isEmpty && values.count <= 4 && values.count == row.value.split(separator:",").count && Set(values).count == values.count && values.allSatisfy { (10...2000).contains($0) })
            case "dhikr.haptics": try check(["true","false"].contains(row.value))
            default: throw PlanError.invalid("validation.data")
            }
        }
    }
}
