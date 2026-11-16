import XCTest
@testable import MIHENCore

final class CapacityRoutineTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
    func capacity() -> BackupDocument {
        var data=BackupDocument.fresh()
        data.capacities=(1...7).map { .init(weekday:$0,minutes:$0 == 2 ? 30 : $0 == 3 ? 60 : 0) }
        return data
    }
    func testCapacityDistributionPreservesDiscreteTotalsAndDailyLimits() throws {
        let data=capacity(),start=engine.date("2026-11-16")!,end=engine.date("2026-11-17")!
        let proposal=try engine.capacityAllocations(total:3,unit:"books",minutesPerUnit:30,from:start,through:end,weekdays:Set(1...7),in:data)
        XCTAssertEqual(proposal.map(\.amount),[1,2]);XCTAssertEqual(proposal.reduce(0) { $0+$1.amount },3)
        XCTAssertThrowsError(try engine.capacityAllocations(total:4,unit:"books",minutesPerUnit:30,from:start,through:end,weekdays:Set(1...7),in:data))
        let minutes=try engine.capacityAllocations(total:60,unit:"minutes",minutesPerUnit:1,from:start,through:end,weekdays:Set(1...7),in:data)
        XCTAssertEqual(minutes.reduce(0) { $0+$1.amount },60)
    }
    func testUnknownWorkCannotBeAssumedToFitAndDurationHistoryIsNotRewritten() throws {
        var data=capacity();let day=engine.date("2026-11-16")!
        data.tasks=[.init(id:"t",title:"Walk",domainID:"health",start:day,recurrence:"daily")]
        engine.materialize(&data,from:day,through:engine.addingDays(1,to:day))
        XCTAssertEqual(engine.workload(data,on:day).unknown,1)
        XCTAssertThrowsError(try engine.capacityAllocations(total:1,unit:"count",minutesPerUnit:1,from:day,through:day,weekdays:Set(1...7),in:data))
        try data.setTaskEstimate("t",minutes:20,engine:engine,on:day)
        XCTAssertEqual(engine.workload(data,on:day).minutes,20)
        let snapshot=data.occurrenceEstimates.first { estimate in data.occurrences.first { $0.id == estimate.occurrenceID }?.day == engine.key(day) }!
        try data.setTaskEstimate("t",minutes:10,engine:engine,on:engine.addingDays(1,to:day))
        XCTAssertEqual(data.occurrenceEstimates.first { $0.id == snapshot.id },snapshot)
        XCTAssertEqual(engine.workload(data,on:engine.addingDays(1,to:day)).minutes,10)
    }
    func testThreeWeeklyFocusItemsAreExplicitAndPreserveTheSelectedTitle() throws {
        var data=capacity();let day=engine.date("2026-11-16")!
        data.tasks=[.init(id:"t",title:"Chosen title",domainID:"health",start:day)]
        try data.setWeeklyFocus(week:day,items:[("task","t")],engine:engine)
        data.tasks[0].title="Changed later"
        XCTAssertEqual(data.weeklyFocuses.first?.title,"Chosen title")
        XCTAssertThrowsError(try data.setWeeklyFocus(week:day,items:[("task","t"),("task","t")],engine:engine))
        XCTAssertEqual(data.weeklyFocuses.count,1)
    }
    func testRoutinePauseOnlyAffectsItsGroupAndSessionCannotDoubleCount() throws {
        var data=capacity();let day=engine.date("2026-11-16")!
        data.tasks=[.init(id:"t",title:"Shared",domainID:"health",start:day,recurrence:"daily")]
        data.routines=[.init(id:"r1",title:"First",domainID:"health"),.init(id:"r2",title:"Second",domainID:"health")]
        data.routineItems=[.init(routineID:"r1",taskID:"t"),.init(routineID:"r2",taskID:"t")]
        engine.materialize(&data,from:day,through:day)
        let before=data.occurrences
        try engine.pauseRoutine("r1",paused:true,in:&data)
        XCTAssertFalse(engine.routineIsAvailable("r1",on:day,in:data));XCTAssertTrue(engine.routineIsAvailable("r2",on:day,in:data))
        XCTAssertFalse(data.tasks[0].archived);XCTAssertEqual(data.occurrences,before)
        let first=try engine.beginRoutine("r2",on:day,in:&data)
        XCTAssertEqual(try engine.beginRoutine("r2",on:day,in:&data),first)
        XCTAssertEqual(data.routineSessions.count,1);XCTAssertEqual(data.occurrences,before)
        data.routineSessions[0].position=1
        XCTAssertEqual(engine.summary(data,on:day).completed,0)
        try BackupCodec.validate(data)
    }
}
