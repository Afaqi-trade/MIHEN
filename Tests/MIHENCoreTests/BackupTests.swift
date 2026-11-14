import XCTest
@testable import MIHENCore

final class BackupTests: XCTestCase {
    func testNutritionAndQadaRoundTripAndInvalidUnits() throws {
        var data = BackupDocument.fresh()
        data.activities.append(.init(domainID: "health", kind: "food", amount: 450, unit: "kcal"))
        data.activities.append(.init(domainID: "spiritual", kind: "qadaDebt", amount: 10, unit: "fajr"))
        data.activities.append(.init(domainID: "spiritual", kind: "qadaDone", amount: 2, unit: "fajr"))
        for index in data.activities.indices { data.activities[index].date = Date(timeIntervalSince1970: 1_700_000_000) }
        let restored = try BackupCodec.decode(BackupCodec.encode(data))
        XCTAssertEqual(restored.activities, data.activities)
        data.activities[0].unit = "ml"
        XCTAssertThrowsError(try BackupCodec.validate(data))
        data.activities[0].unit = "kcal"
        data.activities[2].amount = 11
        XCTAssertThrowsError(try BackupCodec.validate(data))
    }

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
