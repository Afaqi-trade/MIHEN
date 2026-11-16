import XCTest
import SwiftData
import PDFKit
@testable import MIHEN

@MainActor final class PersistenceTests: XCTestCase {
    func testV1StoreMigratesWithoutChangingHistoricalRows() throws {
        let folder=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:folder) }
        try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)
        let url=folder.appendingPathComponent("upgrade.store")
        do {
            let schema=Schema(versionedSchema:MihenSchemaV1.self)
            let config=ModelConfiguration(schema:schema,url:url,cloudKitDatabase:.none)
            let container=try ModelContainer(for:schema,configurations:[config])
            let context=ModelContext(container)
            context.insert(UserPreferences(.init(name:"V1 korunur")))
            for row in BackupDocument.fresh().domains { context.insert(LifeDomain(row)) }
            context.insert(JournalEntry(.init(id:"old-note",text:"Geçmiş değişmez")))
            try context.save()
        }
        let repository=try Repository(storeURL:url)
        var migrated=try repository.load()
        XCTAssertEqual(migrated.preferences.first?.name,"V1 korunur")
        XCTAssertEqual(migrated.journals.first?.text,"Geçmiş değişmez")
        XCTAssertTrue(migrated.sourceLinks.isEmpty)
        migrated.setOption("water.quick",value:"200,400")
        try repository.save(migrated)
        XCTAssertEqual(try Repository(storeURL:url).load().option("water.quick"),"200,400")
    }
    func testRecoveryBackupPreservesValidSnapshotOnInvalidReplacement() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("recovery.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        var document = BackupDocument.fresh()
        document.journals.append(.init(text: "Aktarma öncesi"))
        try RecoveryBackup.preserve(document, at: url)
        var invalid = document
        invalid.domains.removeAll()
        XCTAssertThrowsError(try RecoveryBackup.preserve(invalid, at: url))
        XCTAssertEqual(try RecoveryBackup.load(from: url).journals.first?.text, "Aktarma öncesi")
    }

    func testRecoveryEnvelopeIncludesPrayerAndRejectsInvalidSettingsBeforeOverwriting() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("recovery.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let document = BackupDocument.fresh()
        let settings = PrayerSettings(latitude:41.0082,longitude:28.9784,timeZoneID:"Europe/Istanbul",method:"turkey",hanafi:true)
        try RecoveryBackup.preserve(document,prayer:settings,at:url)
        XCTAssertEqual(try RecoveryBackup.loadArchive(from:url).prayer,settings)
        var invalid=settings;invalid.longitude=200
        XCTAssertThrowsError(try RecoveryBackup.preserve(document,prayer:invalid,at:url))
        XCTAssertEqual(try RecoveryBackup.loadArchive(from:url).prayer,settings)
    }
    func testArchiveImportPersistsRecordsAcrossRepositoryReopen() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:folder) }
        let url=folder.appendingPathComponent("restore.store")
        var document=BackupDocument.fresh(); document.journals.append(.init(text:"Geri yükleme örneği"))
        let archive=try BackupArchive.decode(BackupArchive(document:document).encoded())
        do { let repository=try Repository(storeURL:url);try repository.save(archive.document) }
        XCTAssertEqual(try Repository(storeURL:url).load().journals.first?.text,"Geri yükleme örneği")
    }

    func testNativePeriodReportPDFHasReadableTurkishTextAndMultiplePages() throws {
        let bytes=PeriodReportPDF.render(title:"MİHEN dönem raporu",paragraphs:["Örnek test kaydı: Sabah kalan 8"] + Array(repeating:"Türkçe kayıt örneği: okunan sayfalar, günlük adımlar ve kişisel değerlendirme.",count:120))
        let pdf=try XCTUnwrap(PDFDocument(data:bytes))
        XCTAssertTrue(pdf.pageCount >= 2)
        XCTAssertTrue(pdf.string?.contains("Sabah kalan 8") == true)
        let attachment=XCTAttachment(data:bytes,uniformTypeIdentifier:"com.adobe.pdf")
        attachment.name="MIHEN-Report-PDF-Test";attachment.lifetime = .keepAlways;add(attachment)
    }

    func testSaveReopenPartialProgressAndTurkishText() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("test.store")
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let day = engine.date("2026-11-14")!
        var data = BackupDocument.fresh()
        data.preferences[0].name = "İsmail"
        data.tasks.append(.init(id: "read", title: "Kur'an okuma", domainID: "learning", start: day, recurrence: "daily", target: 6))
        engine.materialize(&data, from: day, through: day)
        try PlanningEngine.setProgress(2, occurrence: &data.occurrences[0])
        do {
            let repository = try Repository(storeURL: url)
            try repository.save(data)
        }
        let reopened = try Repository(storeURL: url)
        let loaded = try reopened.load()
        XCTAssertEqual(loaded.preferences.first?.name, "İsmail")
        XCTAssertEqual(loaded.occurrences.first?.value, 2)
        XCTAssertEqual(loaded.occurrences.first?.status, "partial")
    }
    func testInvalidSaveDoesNotDestroyPersistedData() throws {
        let repository = try Repository(inMemory: true)
        let data = BackupDocument.fresh()
        try repository.save(data)
        var invalid = data
        invalid.domains.removeLast()
        XCTAssertThrowsError(try repository.save(invalid))
        XCTAssertEqual(try repository.load().domains.count, 8)
    }
    func testDeleteAllRemovesEveryEntity() throws {
        let repository = try Repository(inMemory: true)
        var data = BackupDocument.fresh()
        data.journals.append(.init(text: "Private note"))
        data.khatms.append(.init(title: "Reading plan"))
        try repository.save(data)
        try repository.save(.fresh())
        let result = try repository.load()
        XCTAssertTrue(result.journals.isEmpty)
        XCTAssertTrue(result.khatms.isEmpty)
        XCTAssertEqual(result.domains.count, 8)
    }
    func testImportRestoreThroughRepository() throws {
        let repository = try Repository(inMemory: true)
        var data = BackupDocument.fresh()
        data.journals.append(.init(text: "Yedek • Türkçe"))
        let bytes = try BackupCodec.encode(data)
        try repository.save(.fresh())
        try repository.save(BackupCodec.decode(bytes))
        XCTAssertEqual(try repository.load().journals.first?.text, "Yedek • Türkçe")
    }
    func testTemplateLabelsAreTranslatedAndCustomTitlesRemainLiteral() {
        XCTAssertEqual(Localization.recordTitle("template.quran", language: "tr"), "Kur'an okuma")
        XCTAssertEqual(Localization.recordTitle("template.quran", language: "en"), "Quran reading")
        XCTAssertEqual(Localization.recordTitle("today", language: "tr"), "today")
    }

}
