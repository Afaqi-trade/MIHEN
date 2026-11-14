// Generated from Tests/MIHENCoreTests.
import XCTest
@testable import MIHEN

final class BackupTests: XCTestCase {
    func testJSONRoundTripAndDiskPersistence() throws {
        var document = BackupDocument.fresh()
        document.exportedAt = Date(timeIntervalSince1970: 1000)
        document.preferences[0].name = "İsmail — Türkçe"
        let bytes = try BackupCodec.encode(document)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: url) }
        try bytes.write(to: url, options: .atomic)
        XCTAssertEqual(try BackupCodec.decode(Data(contentsOf: url)), document)
    }
    func testCorruptJSONAndUnknownVersionRejected() throws {
        XCTAssertThrowsError(try BackupCodec.decode(Data("{bad}".utf8)))
        var document = BackupDocument.fresh()
        document.version = 200
        XCTAssertThrowsError(try BackupCodec.encode(document))
    }
    func testDuplicateIDsAndDanglingReferencesRejected() {
        var data = BackupDocument.fresh()
        data.domains[1].id = data.domains[0].id
        XCTAssertThrowsError(try BackupCodec.validate(data))
        data = .fresh()
        data.goalProgress = [.init(goalID: "absent", amount: 2)]
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }
    func testDuplicateOccurrencesRejected() {
        var data = BackupDocument.fresh()
        data.tasks = [.init(id: "t", title: "Read", domainID: "learning")]
        let item = TaskOccurrenceRecord(taskID: "t", day: "2024-01-01", title: "Read", domainID: "learning")
        data.occurrences = [item, item]
        data.occurrences[1].id = "second"
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }
    func testGoalCyclesRejected() {
        var data = BackupDocument.fresh()
        data.goals = [.init(id: "a", title: "A", domainIDs: ["learning"], parentID: "b"), .init(id: "b", title: "B", domainIDs: ["learning"], parentID: "a")]
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }
    func testInvalidProgressAndPagesRejected() {
        var data = BackupDocument.fresh()
        data.khatms = [.init(id: "k", totalPages: 604)]
        data.readings = [.init(khatmID: "k", pages: 605)]
        XCTAssertThrowsError(try BackupCodec.validate(data))
        data.readings[0].pages = -1
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }
    func testCSVQuotingMultilineCRLFAndTurkish() throws {
        let rows = [["a", "b"], ["İlim, irfan", "Bir \"not\"\nİkinci satır"], ["", ""]]
        XCTAssertEqual(try CSV.parse(CSV.encode(rows)), rows)
        XCTAssertThrowsError(try CSV.parse("\"unfinished"))
        XCTAssertThrowsError(try CSV.parse("\"a\"oops,b"))
        XCTAssertEqual(CSV.safeCell("=SUM(A1)"), "'=SUM(A1)")
    }
    func testLosslessBackupCSV() throws {
        var document = BackupDocument.fresh()
        document.journals = [.init(text: "Türkçe, \"alıntı\"\nİkinci satır")]
        document.journals[0].date = Date(timeIntervalSince1970: 1000)
        let text = try BackupCodec.exportCSV(document)
        let restored = try BackupCodec.importCSV(text)
        XCTAssertEqual(restored.journals, document.journals)
        XCTAssertEqual(restored.domains, document.domains)
        XCTAssertEqual(restored.preferences, document.preferences)
    }
    func testReadablePlanCSVMappingAndDuplicatePreview() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let rows = [PlanCSV.header, ["task", "test-id", "Kur'an", LifeArea.learning.titleTR, "6", "pages", "2024-01-01", "2024-12-31", "daily"]]
        var data = BackupDocument.fresh()
        let preview = try PlanCSV.preview(CSV.encode(rows), into: data, engine: engine)
        XCTAssertTrue(preview.canImport)
        XCTAssertEqual(preview.tasks.first?.domainID, "learning")
        data.tasks = preview.tasks
        let duplicate = try PlanCSV.preview(CSV.encode(rows), into: data, engine: engine)
        XCTAssertFalse(duplicate.canImport)
        XCTAssertEqual(duplicate.errors.count, 1)
        let exported = PlanCSV.export(data, engine: engine)
        XCTAssertTrue(exported.contains("test-id"))
    }
    func testResetContainsOnlyEmptyEightDomainsAndPreferences() throws {
        let reset = BackupDocument.fresh()
        XCTAssertEqual(reset.domains.count, 8)
        XCTAssertTrue(reset.tasks.isEmpty)
        XCTAssertTrue(reset.journals.isEmpty)
        try BackupCodec.validate(reset)
    }
    func testHostilePageAmountsAreRejectedWithoutOverflow() {
        var data = BackupDocument.fresh()
        data.khatms = [.init(id: "k", title: "Read")]
        data.readings = [.init(khatmID: "k", pages: Int.max), .init(khatmID: "k", pages: Int.max)]
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }
    func testInvalidTimeZoneAndDayRejected() {
        var data = BackupDocument.fresh()
        data.preferences[0].timeZoneID = "Not/A_Zone"
        XCTAssertThrowsError(try BackupCodec.validate(data))
        data = .fresh()
        data.tasks = [.init(id: "t", title: "T", domainID: "learning")]
        data.occurrences = [.init(taskID: "t", day: "2024-02-30", title: "T", domainID: "learning")]
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }

    func testSpreadsheetCellsDoNotExecuteUserTextAndRemainReversible() throws {
        let engine = PlanningEngine(timeZone: TimeZone(secondsFromGMT: 0)!)
        var data = BackupDocument.fresh()
        data.tasks = [.init(id: "=id", title: "'=original", domainID: "learning", start: engine.date("2024-01-01")!, end: engine.date("2024-12-31")!, unit: "=unit")]
        let csv = PlanCSV.export(data, engine: engine)
        let rows = try CSV.parse(csv)
        XCTAssertEqual(rows[1][1], "'=id")
        XCTAssertEqual(rows[1][2], "''=original")
        XCTAssertEqual(rows[1][5], "'=unit")
        let preview = try PlanCSV.preview(csv, into: .fresh(), engine: engine)
        XCTAssertTrue(preview.canImport)
        XCTAssertEqual(preview.tasks.first?.id, "=id")
        XCTAssertEqual(preview.tasks.first?.title, "'=original")
        XCTAssertEqual(preview.tasks.first?.unit, "=unit")
        let backup = try BackupCodec.importCSV(BackupCodec.exportCSV(data))
        XCTAssertEqual(backup.tasks.first?.id, "=id")
    }

}

import XCTest
@testable import MIHEN

final class PlanningTests: XCTestCase {
    let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
    func date(_ value: String) -> Date { engine.date(value)! }
    func task(_ start: String, _ recurrence: String = "daily", target: Double = 6) -> PlannedTaskRecord {
        .init(id: "task", title: "Kur'an okuma", domainID: "learning", start: date(start), recurrence: recurrence, target: target, unit: "pages")
    }
    func fixture() -> BackupDocument {
        var data = BackupDocument.fresh()
        data.tasks = [task("2024-01-01")]
        return data
    }
    func testExactlyEightDomains() throws {
        let data = BackupDocument.fresh()
        XCTAssertEqual(data.domains.count, 8)
        try BackupCodec.validate(data)
    }
    func testDailyCreationIsIdempotent() throws {
        var data = fixture()
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-03"))
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-03"))
        XCTAssertEqual(data.occurrences.count, 3)
        try BackupCodec.validate(data)
    }
    func testPartialAndCompleted() throws {
        var data = fixture()
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        XCTAssertEqual(data.occurrences[0].value, 2)
        XCTAssertEqual(data.occurrences[0].status, "partial")
        XCTAssertEqual(engine.summary(data, on: date("2024-01-01")).partial, 1)
        try PlanningEngine.setProgress(100, occurrence: &data.occurrences[0])
        XCTAssertEqual(data.occurrences[0].value, 6)
        XCTAssertEqual(engine.summary(data, on: date("2024-01-01")).ratio, 1)
        XCTAssertThrowsError(try PlanningEngine.setProgress(-1, occurrence: &data.occurrences[0]))
    }
    func testMonthlyUsesOriginalAnchorAndLeapYear() {
        let t = task("2024-01-31", "monthly")
        XCTAssertTrue(engine.isDue(t, on: date("2024-02-29")))
        XCTAssertFalse(engine.isDue(t, on: date("2024-02-28")))
        XCTAssertTrue(engine.isDue(t, on: date("2024-03-31")))
        XCTAssertTrue(engine.isDue(t, on: date("2025-02-28")))
    }
    func testYearlyLeapDay() {
        let t = task("2024-02-29", "yearly")
        XCTAssertTrue(engine.isDue(t, on: date("2025-02-28")))
        XCTAssertFalse(engine.isDue(t, on: date("2025-03-01")))
    }
    func testWeeklyScheduleAndEnd() {
        var t = task("2024-01-01", "weekly")
        t.end = date("2024-01-15")
        XCTAssertTrue(engine.isDue(t, on: date("2024-01-08")))
        XCTAssertFalse(engine.isDue(t, on: date("2024-01-09")))
        XCTAssertFalse(engine.isDue(t, on: date("2024-01-22")))
    }
    func testRestDaysAndStreak() throws {
        var data = fixture()
        data.tasks[0].isHabit = true
        data.preferences[0].restWeekdays = [1, 7]
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-08"))
        XCTAssertEqual(data.occurrences.count, 6)
        for i in data.occurrences.indices { try PlanningEngine.setProgress(6, occurrence: &data.occurrences[i]) }
        XCTAssertEqual(engine.streak(taskID: "task", data: data, through: date("2024-01-08")), 6)
    }
    func testEmptySummaryHasNoFabricatedPercentage() {
        XCTAssertNil(engine.summary(.fresh(), on: date("2024-01-01")).ratio)
    }
    func testHistoricalSnapshotDoesNotChangeWithTemplate() {
        var data = fixture()
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        data.tasks[0].target = 100
        data.tasks[0].title = "Changed"
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        XCTAssertEqual(data.occurrences[0].target, 6)
        XCTAssertEqual(data.occurrences[0].title, "Kur'an okuma")
    }
    func testMovePreservesHistoryAndAvoidsDuplicates() throws {
        var data = fixture()
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        let id = data.occurrences[0].id
        try engine.move(id, to: date("2024-01-02"), in: &data)
        XCTAssertEqual(data.occurrences[0].status, "moved")
        XCTAssertEqual(data.occurrences[0].value, 2)
        XCTAssertEqual(data.occurrences[1].originalDay, "2024-01-01")
        XCTAssertThrowsError(try engine.move(data.occurrences[1].id, to: date("2024-01-01"), in: &data))
        try BackupCodec.validate(data)
    }
    func testGoalProgressAndSafeDelete() throws {
        var data = fixture()
        data.goals = [.init(id: "goal", title: "Read", domainIDs: ["learning"], start: date("2024-01-01"), end: date("2024-12-31"), target: 100, unit: "pages")]
        data.tasks[0].goalID = "goal"
        data.goalProgress = [.init(goalID: "goal", amount: 3)]
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        XCTAssertEqual(engine.goalValue("goal", in: data), 5)
        data.deleteGoal("goal")
        XCTAssertNil(data.tasks[0].goalID)
        XCTAssertNil(data.occurrences[0].goalID)
        XCTAssertTrue(data.goalProgress.isEmpty)
        try BackupCodec.validate(data)
    }
    func testHatimPacingUses366DaysAndProgress() {
        XCTAssertEqual(engine.remainingPerDay(total: 604, completed: 0, start: date("2024-01-01"), end: date("2024-12-31"), now: date("2024-01-01")), 2)
        XCTAssertEqual(engine.remainingPerDay(total: 604, completed: 600, start: date("2024-01-01"), end: date("2024-12-31"), now: date("2024-12-30")), 2)
        XCTAssertEqual(engine.remainingPerDay(total: 604, completed: 604, start: date("2024-01-01"), end: date("2024-12-31"), now: date("2025-01-01")), 0)
    }
    func testMemorizationSchedule() {
        let item = MemorizationItemRecord(id: "surah", title: "Mülk", lastVerse: 30)
        XCTAssertNil(engine.nextReview(item, reviews: []))
        let first = MemorizationReviewRecord(itemID: "surah", date: date("2024-01-01"))
        XCTAssertEqual(engine.key(engine.nextReview(item, reviews: [first])!), "2024-01-02")
        let second = MemorizationReviewRecord(itemID: "surah", date: date("2024-01-02"))
        XCTAssertEqual(engine.key(engine.nextReview(item, reviews: [first, second])!), "2024-01-05")
    }
    func testFastingPlannedIsNotCompleted() throws {
        var data = fixture()
        data.fasts = [.init(title: "Kişisel plan"), .init(title: "İkinci gün", status: "completed")]
        XCTAssertEqual(data.fasts.filter { $0.status == "completed" }.count, 1)
        try BackupCodec.validate(data)
    }
    func testWeeklyMonthlySummaryDenominator() throws {
        var data = fixture()
        engine.materialize(&data, from: date("2024-02-01"), through: date("2024-02-29"))
        for i in 0..<7 { try PlanningEngine.setProgress(6, occurrence: &data.occurrences[i]) }
        let summaries = engine.days(from: date("2024-02-01"), through: date("2024-02-29")).map { engine.summary(data, on: $0) }
        XCTAssertEqual(summaries.reduce(0) { $0 + $1.planned }, 29)
        XCTAssertEqual(summaries.reduce(0) { $0 + $1.completed }, 7)
    }
    func testDSTCalendarDaysAndTimeZones() {
        let ny = PlanningEngine(timeZone: TimeZone(identifier: "America/New_York")!)
        let days = ny.days(from: ny.date("2024-03-09")!, through: ny.date("2024-03-11")!)
        XCTAssertEqual(days.count, 3)
        XCTAssertEqual(days[2].timeIntervalSince(days[1]), 23 * 3600)
        let instant = ISO8601DateFormatter().date(from: "2024-01-01T22:00:00Z")!
        XCTAssertEqual(engine.key(instant), "2024-01-02")
        XCTAssertEqual(ny.key(instant), "2024-01-01")
        XCTAssertNil(engine.date("2024-02-30"))
    }
    func testHijriRecurrenceUsesDocumentedCalendar() {
        let t = task("2024-01-01", "hijriMonthly")
        let next = engine.hijriCalendar.date(byAdding: .month, value: 1, to: t.start)!
        XCTAssertTrue(engine.isDue(t, on: next))
    }
    func testTemplatesAreOptInIdempotentAndIncomplete() {
        var data = BackupDocument.fresh()
        XCTAssertTrue(data.tasks.isEmpty)
        data.addStarterTemplates(on: date("2024-01-01"), engine: engine)
        data.addStarterTemplates(on: date("2024-01-01"), engine: engine)
        XCTAssertEqual(data.tasks.count, 8)
        XCTAssertTrue(data.occurrences.allSatisfy { $0.value == 0 })
    }
    func testRedistributionPreservesTotalAndPartialHistory() throws {
        var data = fixture()
        data.goals = [.init(id: "g", title: "Read", domainIDs: ["learning"], target: 100, unit: "pages")]
        data.tasks[0].goalID = "g"
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        let id = data.occurrences[0].id
        let proposal = try engine.redistributionProposal(data.occurrences[0], from: date("2024-01-02"), through: date("2024-01-03"), in: data)
        XCTAssertEqual(proposal.map(\.target).reduce(0, +), 6)
        try engine.redistribute(id, from: date("2024-01-02"), through: date("2024-01-03"), in: &data)
        XCTAssertEqual(data.occurrences[0].status, "moved")
        XCTAssertEqual(engine.goalValue("g", in: data), 2)
        XCTAssertEqual(data.occurrences.filter { $0.status != "moved" }.count, 2)
        try BackupCodec.validate(data)
    }
    func testDifferentUnitsAreNotSummedIntoGoal() throws {
        var data = fixture()
        data.goals = [.init(id: "g", title: "Books", domainIDs: ["learning"], target: 24, unit: "books")]
        data.tasks[0].goalID = "g"
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(6, occurrence: &data.occurrences[0])
        XCTAssertEqual(engine.goalValue("g", in: data), 0)
    }
    func testCancelledPartialActivityRemainsInGoalHistory() throws {
        var data = fixture()
        data.goals = [.init(id: "g", title: "Pages", domainIDs: ["learning"], target: 100, unit: "pages")]
        data.tasks[0].goalID = "g"
        engine.materialize(&data, from: date("2024-01-01"), through: date("2024-01-01"))
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        data.occurrences[0].status = "cancelled"
        XCTAssertEqual(engine.goalValue("g", in: data), 2)
        XCTAssertNil(engine.summary(data, on: date("2024-01-01")).ratio)
    }

}
