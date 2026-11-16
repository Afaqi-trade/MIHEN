import XCTest
@testable import MIHENCore

final class ProductPlanningTests: XCTestCase {
    let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
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
        invalid=archive; invalid.archiveVersion=2
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
