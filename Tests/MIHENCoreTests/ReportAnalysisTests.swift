import XCTest
@testable import MIHENCore

final class ReportAnalysisTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Berlin")!)
    func testEqualDayComparisonCrossesDSTAndMissingIsNotZero() throws {
        let end=engine.date("2026-03-31")!,start=engine.date("2026-03-28")!
        let interval=DateInterval(start:start,end:end),prior=engine.previousEqualInterval(.init(start:start,end:end))
        XCTAssertEqual(engine.key(prior.start),"2026-03-25")
        XCTAssertEqual(prior.end,start)
        var data=BackupDocument.fresh()
        for index in 0..<3 {
            data.activities.append(.init(domainID:"health",date:engine.addingDays(index,to:start),kind:"water",amount:250,unit:"ml"))
            data.activities.append(.init(domainID:"health",date:engine.addingDays(index,to:prior.start),kind:"water",amount:200,unit:"ml"))
        }
        data.activities.append(.init(domainID:"health",date:start,kind:"food",amount:500,unit:"kcal"))
        let analysis=engine.analyzeReport(data,interval:interval,component:.weekOfYear)
        let water=analysis.comparisons.first { $0.metric.key == "activity.water" }!
        XCTAssertEqual(water.current,750);XCTAssertEqual(water.previous,600);XCTAssertEqual(water.difference,150)
        let food=analysis.comparisons.first { $0.metric.key == "activity.food" }!
        XCTAssertNil(food.previous);XCTAssertNil(food.difference)
    }
    func testTenYearBucketsDoNotInventEarlierHistoryOrIncludeFuture() throws {
        let now=engine.date("2026-11-17")!,interval=engine.reportInterval(period:"report.tenYears",containing:now,now:now)
        XCTAssertEqual(engine.key(interval.start),"2017-01-01");XCTAssertEqual(engine.key(interval.end),"2026-11-18")
        var data=BackupDocument.fresh()
        data.activities=[.init(domainID:"health",date:now,kind:"water",amount:250,unit:"ml"),.init(domainID:"health",date:engine.addingDays(1,to:now),kind:"water",amount:999,unit:"ml")]
        let result=engine.analyzeReport(data,interval:interval,component:.year)
        XCTAssertEqual(result.buckets.count,10)
        XCTAssertTrue(result.buckets.dropLast().allSatisfy { $0.report.recordedDays.isEmpty && $0.report.metrics.isEmpty })
        XCTAssertEqual(result.current.metrics.first?.value,250)
        XCTAssertEqual(result.firstRecordedDay,"2026-11-17")
    }
    func testScopedReportExcludesPrivateNotesAndStructuredResponses() throws {
        var data=BackupDocument.fresh()
        data.journals=[.init(id:"private",domainID:"family",kind:"weekly",text:"Private"),.init(id:"chosen",domainID:"health",kind:"weekly",text:"Chosen")]
        data.reviewResponses=[.init(journalID:"private",well:"Private answer"),.init(journalID:"chosen",next:"Walk")]
        XCTAssertTrue(data.scopedReport(areas:["health"],includeNotes:false).reviewResponses.isEmpty)
        let scope=data.scopedReport(areas:["health"],includeNotes:true)
        XCTAssertEqual(scope.journals.map(\.id),["chosen"])
        XCTAssertEqual(scope.reviewResponses.map(\.next),["Walk"])
        let restored=try BackupCodec.decode(BackupCodec.encode(data))
        XCTAssertEqual(restored.reviewResponses,data.reviewResponses)
        var bad=data;bad.reviewResponses.append(.init(journalID:"missing"));XCTAssertThrowsError(try BackupCodec.validate(bad))
    }
}
