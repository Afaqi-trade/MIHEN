import XCTest
@testable import MIHENCore

final class ProductPlanningTests: XCTestCase {
    let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
    func testFirstPlanningWeekUsesSevenCalendarDaysAndDoesNotReallocate() throws {
        let london = PlanningEngine(timeZone: TimeZone(identifier: "Europe/London")!)
        let start = london.date("2026-03-27")!
        let original = try london.allocations(total: 10, unit: "pages", from: start, through: london.addingDays(9, to: start))
        let first = london.firstPlanningWeek(original, from: start)
        XCTAssertEqual(first.map(\.day), ["2026-03-27", "2026-03-28", "2026-03-29", "2026-03-30", "2026-03-31", "2026-04-01", "2026-04-02"])
        XCTAssertEqual(first.reduce(0.0) { $0 + $1.amount }, 7)
        XCTAssertEqual(original.reduce(0.0) { $0 + $1.amount }, 10)
        XCTAssertTrue(london.firstPlanningWeek(original, from: london.addingDays(20, to: start)).isEmpty)
    }
    func testSparseWholeAllocationsAndExactMoneyTotals() throws {
        let start = engine.date("2026-01-01")!, end = engine.date("2026-12-31")!
        let books = try engine.allocations(total: 24, unit: "books", from: start, through: end)
        XCTAssertEqual(books.count, 24)
        XCTAssertTrue(books.allSatisfy { $0.amount == 1 })
        XCTAssertEqual(books.first?.day, "2026-01-01")
        XCTAssertEqual(books.last?.day, "2026-12-31")
        let pages = try engine.allocations(total: 604, unit: "pages", from: start, through: end)
        XCTAssertEqual(pages.reduce(0) { $0 + $1.amount }, 604)
        XCTAssertTrue(pages.allSatisfy { $0.amount.rounded() == $0.amount })
        let money = try engine.allocations(total: 10.01, unit: "TRY", from: start, through: engine.addingDays(2, to: start))
        XCTAssertEqual(money.map { Int(($0.amount * 100).rounded()) }.reduce(0,+), 1001)
    }
    func testInvalidPrecisionAndDaysRejected() throws {
        let day = engine.date("2026-01-01")!
        XCTAssertThrowsError(try engine.allocations(total: 1.5, unit: "count", from: day, through: day))
        XCTAssertThrowsError(try engine.allocations(total: 1.001, unit: "minutes", from: day, through: day))
        XCTAssertThrowsError(try engine.allocations(total: 2, unit: "count", from: day, through: engine.addingDays(366, to: day)))
        XCTAssertThrowsError(try engine.allocations(total: 2, unit: "count", from: day, through: day, weekdays: []))
    }
    func testApplyUsesProposalAndRejectsSecondPlanWithoutChangingHistory() throws {
        var data = BackupDocument.fresh(); let day = engine.date("2026-11-16")!
        data.goals=[.init(id:"g",title:"Books",domainIDs:["learning"],start:day,end:engine.addingDays(6,to:day),target:3,unit:"books")]
        let expected = try engine.goalAllocations("g", in:data, from:day, through:engine.addingDays(6,to:day), weekdays:Set(1...7))
        try engine.applyGoalPlan("g",from:day,through:engine.addingDays(6,to:day),weekdays:Set(1...7),in:&data)
        XCTAssertEqual(data.tasks.map(\.target),expected.map(\.amount))
        let snapshot=data
        XCTAssertThrowsError(try engine.applyGoalPlan("g",from:day,through:day,weekdays:Set(1...7),in:&data))
        XCTAssertEqual(data,snapshot); try BackupCodec.validate(data)
    }
    func testArchiveLegacyCompatibilityPrayerValidationAndVersions() throws {
        var data=BackupDocument.fresh(); data.exportedAt=engine.date("2026-11-16")!
        let legacy=try BackupArchive.decode(BackupCodec.encode(data))
        XCTAssertEqual(legacy.document,data); XCTAssertNil(legacy.prayer)
        let prayer=PrayerSettings(latitude:41.0082,longitude:28.9784,timeZoneID:"Europe/Istanbul",method:"turkey",hanafi:true)
        let archive=BackupArchive(document:data,prayer:prayer)
        XCTAssertEqual(try BackupArchive.decode(archive.encoded()),archive)
        var invalid=archive; invalid.prayer?.latitude=100
        XCTAssertThrowsError(try invalid.encoded())
        invalid=archive; invalid.archiveVersion=999
        XCTAssertThrowsError(try invalid.encoded())
    }
    func testOnlyExplicitTemplatesAndNoGeneratedSuccess() throws {
        var data=BackupDocument.fresh(); let day=engine.date("2026-11-16")!
        data.addSelectedTemplates(["template.family"],on:day,engine:engine)
        data.addSelectedTemplates(["template.family"],on:day,engine:engine)
        XCTAssertEqual(data.tasks.count,1)
        XCTAssertTrue(data.occurrences.allSatisfy { $0.value == 0 && $0.status == "planned" })
        try BackupCodec.validate(data)
    }
}

extension ProductPlanningTests {
    func testMonthlyAndWeeklyRoadmapTotalsMatchDailyProposal() throws {
        let start = engine.date("2026-01-01")!, end = engine.date("2026-12-31")!
        let proposal = try engine.allocations(total:24,unit:"books",from:start,through:end)
        let months = engine.planningStages(proposal,component:.month)
        let weeks = engine.planningStages(proposal,component:.weekOfYear)
        XCTAssertEqual(months.reduce(0) { $0 + $1.total },24)
        XCTAssertEqual(weeks.reduce(0) { $0 + $1.total },24)
        XCTAssertEqual(months.reduce(0) { $0 + $1.actions },24)
    }
}

extension ProductPlanningTests {
    func testArchivedAndMovedSourceProgressIsNotDuplicatedAcrossPeriods() throws {
        let start=engine.date("2026-11-16")!, end=engine.addingDays(1,to:start)
        var data=BackupDocument.fresh()
        data.goals=[.init(id:"g",title:"Read",domainIDs:["learning"],target:6,unit:"pages")]
        data.tasks=[.init(id:"t",title:"Read",domainID:"learning",goalID:"g",start:start,target:6,unit:"pages")]
        engine.materialize(&data,from:start,through:start)
        try PlanningEngine.setProgress(2,occurrence:&data.occurrences[0])
        let id=data.occurrences[0].id
        try engine.move(id,to:end,in:&data)
        data.goalProgress=[.init(goalID:"g",date:end,amount:1)]
        let whole=engine.contributions("g",in:data)
        XCTAssertEqual(whole.manual,1);XCTAssertEqual(whole.tasks,2);XCTAssertEqual(whole.total,3)
        let firstDay=engine.contributions("g",in:data,interval:DateInterval(start:engine.calendar.startOfDay(for:start),end:engine.calendar.startOfDay(for:end)))
        XCTAssertEqual(firstDay.total,0)
        try BackupCodec.validate(data)
    }
}

extension ProductPlanningTests {
    func testRoutineResumeDoesNotInventTasksDuringPauseAndKeepsHistory() throws {
        var data=BackupDocument.fresh();let start=engine.date("2026-11-01")!
        data.tasks=[.init(id:"t",title:"Walk",domainID:"health",start:start,recurrence:"daily")]
        data.routines=[.init(id:"r",title:"Morning",domainID:"health")]
        data.routineItems=[.init(routineID:"r",taskID:"t")]
        engine.materialize(&data,from:start,through:start)
        try PlanningEngine.setProgress(1,occurrence:&data.occurrences[0])
        let history=data.occurrences[0]
        try engine.changeRoutineRepetitions("r",resume:false,on:start,in:&data)
        try engine.changeRoutineRepetitions("r",resume:true,on:engine.addingDays(3,to:start),in:&data)
        engine.materialize(&data,from:start,through:engine.addingDays(7,to:start))
        XCTAssertEqual(data.occurrences.first { $0.day == engine.key(start) },history)
        for gap in 1...3 { XCTAssertFalse(data.occurrences.contains { $0.day == engine.key(engine.addingDays(gap,to:start)) }) }
        XCTAssertTrue(data.occurrences.contains { $0.day == engine.key(engine.addingDays(4,to:start)) })
        try BackupCodec.validate(data)
    }
}
