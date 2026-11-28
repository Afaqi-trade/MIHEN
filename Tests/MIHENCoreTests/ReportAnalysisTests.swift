import XCTest
@testable import MIHENCore

final class ReportAnalysisTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Berlin")!)
    func testDailyReportDistinguishesPlannedAndObservedFasts() throws {
        let day = engine.date("2026-03-29")!
        let interval = engine.reportInterval(period: "day", containing: day, now: engine.addingDays(2, to: day))
        XCTAssertEqual(engine.key(interval.start), "2026-03-29")
        XCTAssertEqual(engine.key(interval.end), "2026-03-30")
        var data = BackupDocument.fresh()
        data.fasts = [
            .init(date: day, title: "Tutulan", status: "completed"),
            .init(date: day, title: "Plan", status: "planned"),
            .init(date: day, title: "İptal", status: "cancelled"),
            .init(date: engine.addingDays(1, to: day), title: "Yarın", status: "planned")
        ]
        let report = engine.periodReport(data, in: interval)
        XCTAssertEqual(report.metrics.first { $0.key == "report.fasts" }?.value, 1)
        XCTAssertEqual(report.metrics.first { $0.key == "report.fasts.planned" }?.value, 1)
        XCTAssertEqual(report.metrics.first { $0.key == "report.fasts.planned" }?.unit, "count")
        XCTAssertEqual(report.recordedDays, ["2026-03-29"])
        let plannedOnly = engine.periodReport(data, in: .init(start: engine.addingDays(1, to: day), end: engine.addingDays(2, to: day)))
        XCTAssertTrue(plannedOnly.recordedDays.isEmpty)
        XCTAssertEqual(plannedOnly.metrics.first { $0.key == "report.fasts.planned" }?.value, 1)
    }
    func testNutritionPlanDoesNotBecomeAnActualRecord() throws {
        let day = engine.date("2026-11-10")!
        var data = BackupDocument.fresh()
        data.nutritionPlans = [.init(date: day, kind: "water", amount: 500, unit: "ml")]
        let interval = DateInterval(start: day, end: engine.addingDays(1, to: day))
        let report = engine.periodReport(data, in: interval)
        XCTAssertEqual(report.metrics.first { $0.key == "report.nutrition.planned.water" }?.value, 500)
        XCTAssertNil(report.metrics.first { $0.key == "activity.water" })
        XCTAssertTrue(report.recordedDays.isEmpty)
        let scoped = data.scopedReport(areas: ["spiritual"], includeNotes: false)
        XCTAssertTrue(engine.periodReport(scoped, in: interval).metrics.isEmpty)
    }
    func testQadaMetricCoverageDoesNotMixDebtAndCompletedPrayerDays() throws {
        let start = engine.date("2026-11-08")!
        let previous = engine.addingDays(-7, to: start)
        var data = BackupDocument.fresh()
        for offset in 0..<3 {
            data.activities.append(.init(domainID: "spiritual", date: engine.addingDays(offset, to: start), kind: "qadaDebt", amount: 2, unit: "fajr"))
            data.activities.append(.init(domainID: "spiritual", date: engine.addingDays(offset, to: previous), kind: "qadaDebt", amount: 1, unit: "fajr"))
        }
        data.activities.append(.init(domainID: "spiritual", date: start, kind: "qadaDone", amount: 1, unit: "fajr"))
        data.activities.append(.init(domainID: "spiritual", date: previous, kind: "qadaDone", amount: 1, unit: "fajr"))
        let result = engine.analyzeReport(data, interval: .init(start: start, end: engine.addingDays(7, to: start)), component: .day)
        let done = result.comparisons.first { $0.metric.key == "report.qada.done" && $0.metric.unit == "fajr" }!
        let added = result.comparisons.first { $0.metric.key == "report.qada.added" && $0.metric.unit == "fajr" }!
        XCTAssertEqual(done.currentDays, 1)
        XCTAssertEqual(done.previousDays, 1)
        XCTAssertNil(done.difference)
        XCTAssertEqual(added.currentDays, 3)
        XCTAssertEqual(added.previousDays, 3)
        XCTAssertEqual(added.difference, 3)
    }
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
    func testUnrelatedNotesCannotMakeSparseMetricComparisonLookReliable() throws {
        var data=BackupDocument.fresh();let start=engine.date("2026-11-10")!
        for offset in -3..<3 { data.journals.append(.init(date:engine.addingDays(offset,to:start),text:"Note")) }
        data.activities=[.init(domainID:"health",date:start,kind:"water",amount:250,unit:"ml"),.init(domainID:"health",date:engine.addingDays(-1,to:start),kind:"water",amount:200,unit:"ml")]
        let result=engine.analyzeReport(data,interval:.init(start:start,end:engine.addingDays(3,to:start)),component:.day)
        XCTAssertEqual(result.current.recordedDays.count,3)
        XCTAssertEqual(result.comparisons.first?.currentDays,1)
        XCTAssertNil(result.comparisons.first?.difference)
        XCTAssertTrue(result.current.taskRecordedDays.isEmpty)
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
