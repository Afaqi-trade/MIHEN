import XCTest
@testable import MIHENCore
final class PeriodReportTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
    func testIndependentSourcesHalfOpenCoverageAndQadaBalances() throws {
        var data=BackupDocument.fresh()
        let start=engine.date("2026-11-01")!, end=engine.date("2026-12-01")!
        data.activities=[.init(domainID:"spiritual",date:engine.addingDays(-2,to:start),kind:"qadaDebt",amount:10,unit:"fajr"), .init(domainID:"spiritual",date:start,kind:"qadaDone",amount:2,unit:"fajr"), .init(domainID:"health",date:start,kind:"food",amount:450,unit:"kcal"), .init(domainID:"health",date:end,kind:"food",amount:900,unit:"kcal")]
        let result=engine.periodReport(data,in:DateInterval(start:start,end:end))
        XCTAssertEqual(result.recordedDays.count,1)
        XCTAssertEqual(result.metrics.first { $0.id == "fajropening" }?.value,10)
        XCTAssertEqual(result.metrics.first { $0.id == "fajrclosing" }?.value,8)
        XCTAssertEqual(result.metrics.first { $0.key == "activity.food" }?.value,450)
        XCTAssertEqual(result.planned,0)
        let empty=engine.periodReport(data,in:DateInterval(start:engine.addingDays(1,to:end),end:engine.addingDays(2,to:end)))
        XCTAssertTrue(empty.recordedDays.isEmpty)
    }
    func testArchiveFuturePlanKeepsPastAndRecordedContribution() throws {
        var data=BackupDocument.fresh();let now=engine.date("2026-11-16")!
        data.goals=[.init(id:"g",title:"Read",domainIDs:["learning"],target:10,unit:"pages")]
        data.tasks=[.init(id:"t",title:"Read",domainID:"learning",goalID:"g",start:engine.addingDays(-1,to:now),recurrence:"daily",target:6,unit:"pages")]
        engine.materialize(&data,from:engine.addingDays(-1,to:now),through:engine.addingDays(1,to:now))
        let past=data.occurrences[0]
        try PlanningEngine.setProgress(2,occurrence:&data.occurrences[1])
        engine.archiveFutureGoalPlan("g",on:now,in:&data)
        XCTAssertEqual(data.occurrences[0],past)
        XCTAssertEqual(engine.contributions("g",in:data).tasks,2)
        XCTAssertTrue(data.tasks[0].archived)
        let plan=try engine.goalAllocations("g",in:data,from:now,through:engine.addingDays(2,to:now),weekdays:Set(1...7))
        XCTAssertEqual(plan.map(\.amount).reduce(0,+),8)
        try BackupCodec.validate(data)
    }
}

extension PeriodReportTests {
    func testHealthImportIsIdempotentAndManualEnergyIsRetainedWithoutDoubleCounting() throws {
        var data=BackupDocument.fresh();let day=engine.date("2026-11-16")!
        data.activities=[.init(domainID:"health",date:day,kind:"energyBurned",amount:100,unit:"kcal")]
        try data.recordHealthSummary(on:day,steps:5000,energy:300,engine:engine)
        try data.recordHealthSummary(on:day,steps:5100,energy:310,engine:engine)
        XCTAssertEqual(data.activities.count,3)
        let totals=data.effectiveActivities(engine:engine)
        XCTAssertEqual(totals.filter { $0.kind == "energyBurned" }.reduce(0) { $0 + $1.amount },310)
        let report=engine.periodReport(data,in:DateInterval(start:engine.calendar.startOfDay(for:day),end:engine.addingDays(1,to:engine.calendar.startOfDay(for:day))))
        XCTAssertEqual(report.metrics.first { $0.key == "activity.steps" }?.value,5100)
        data.activities.removeAll { $0.id.hasPrefix("health.energy:") }
        XCTAssertEqual(data.effectiveActivities(engine:engine).filter { $0.kind == "energyBurned" }.reduce(0) { $0 + $1.amount },100)
        let snapshot=data
        XCTAssertThrowsError(try data.recordHealthSummary(on:day,steps:-1,energy:0,engine:engine))
        XCTAssertEqual(data,snapshot)
    }
}
