import XCTest
@testable import MIHENCore

final class SourceLinkTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
    func fixture() -> BackupDocument {
        var data=BackupDocument.fresh();let day=engine.date("2026-11-16")!
        data.goals=[.init(id:"g",title:"Read",domainIDs:["learning"],start:day,end:day,target:12,unit:"pages")]
        data.tasks=[.init(id:"t",title:"Read",domainID:"learning",goalID:"g",start:day,target:12,unit:"pages")]
        data.khatms=[.init(id:"k",title:"Reading",start:day,end:day)]
        data.readings=[.init(id:"r",khatmID:"k",date:day,pages:6)]
        engine.materialize(&data,from:day,through:day);return data
    }
    func testHealthRefreshKeepsLinkedDateAndUpdatesOnlyItsExplicitTask() throws {
        let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
        let day=engine.date("2026-11-17")!
        var data=BackupDocument.fresh()
        data.tasks=[.init(id:"steps",title:"Steps",domainID:"health",start:day,target:1000,unit:"count")]
        engine.materialize(&data,from:day,through:day)
        try data.recordHealthSummary(on:day,steps:100,energy:nil,engine:engine)
        try data.connectSource("activity:health.steps:2026-11-17",to:data.occurrences[0].id,engine:engine)
        try data.recordHealthSummary(on:day.addingTimeInterval(3600),steps:250,energy:nil,engine:engine)
        XCTAssertEqual(data.activities.count,1)
        XCTAssertEqual(data.occurrences[0].value,250)
        XCTAssertEqual(data.sourceLinks[0].sourceDate,engine.calendar.startOfDay(for:day))
        XCTAssertEqual(data.activities[0].date,engine.calendar.startOfDay(for:day))
    }
    func testLinkedReadingReplacesManualAmountDoesNotDoubleCountAndRestoresIt() throws {
        var data=fixture();let id=data.occurrences[0].id
        try PlanningEngine.setProgress(2,occurrence:&data.occurrences[0])
        try data.connectSource("reading:r",to:id,engine:engine)
        XCTAssertEqual(data.occurrences[0].value,6)
        XCTAssertEqual(engine.goalValue("g",in:data),6)
        XCTAssertThrowsError(try data.connectSource("reading:r",to:id,engine:engine))
        data.readings[0].pages=8;try data.reconcileSources(engine:engine)
        XCTAssertEqual(engine.goalValue("g",in:data),8)
        try data.disconnectSource(data.sourceLinks[0].id,engine:engine)
        XCTAssertEqual(data.occurrences[0].value,2)
        XCTAssertEqual(data.readings[0].pages,8)
    }
    func testSourceDeletionRestoresIndependentProgressAndInvalidDateEditIsRejected() throws {
        var data=fixture();let id=data.occurrences[0].id
        try data.connectSource("reading:r",to:id,engine:engine)
        var changed=data;changed.readings[0].date=engine.addingDays(1,to:changed.readings[0].date)
        XCTAssertThrowsError(try changed.reconcileSources(engine:engine))
        XCTAssertEqual(data.occurrences[0].value,6)
        data.readings=[];try data.reconcileSources(engine:engine)
        XCTAssertEqual(data.occurrences[0].value,0);XCTAssertTrue(data.sourceLinks.isEmpty)
        try BackupCodec.validate(data)
    }
    func testSourceRequiresMatchingUnitAndOnlyOneDestination() throws {
        var data=fixture();data.occurrences[0].unit="minutes"
        XCTAssertThrowsError(try data.connectSource("reading:r",to:data.occurrences[0].id,engine:engine))
        data=fixture();let day=data.tasks[0].start
        data.tasks.append(.init(id:"t2",title:"Another",domainID:"learning",start:day,target:12,unit:"pages"))
        engine.materialize(&data,from:day,through:day)
        let first=data.occurrences.first { $0.taskID == "t" }!.id,second=data.occurrences.first { $0.taskID == "t2" }!.id
        try data.connectSource("reading:r",to:first,engine:engine)
        XCTAssertThrowsError(try data.connectSource("reading:r",to:second,engine:engine))
    }
    func testConnectionKeepsItsHistoricalDayWhenDisplayTimeZoneChanges() throws {
        var data=fixture()
        data.readings[0].date=engine.date("2026-11-16")!.addingTimeInterval(900)
        try data.connectSource("reading:r",to:data.occurrences[0].id,engine:engine)
        data.preferences[0].timeZoneID="America/New_York"
        let other=PlanningEngine(timeZone:TimeZone(identifier:"America/New_York")!)
        try data.reconcileSources(engine:other)
        XCTAssertEqual(data.occurrences[0].day,"2026-11-16")
        XCTAssertEqual(data.occurrences[0].value,6)
        try BackupCodec.validate(data)
    }
    func testV1BackupMigratesToV2AndCurrentBackupCannotSilentlyLoseNewTables() throws {
        let data=fixture();let bytes=try BackupCodec.encode(data)
        var old=try JSONSerialization.jsonObject(with:bytes) as! [String:Any]
        let keys=["sourceLinks","capacities","taskEstimates","occurrenceEstimates","goalSupports","weeklyFocuses","routineSchedules","routineSessions","activityAnnotations","nutritionPlans","options","reviewResponses"]
        for key in keys { old.removeValue(forKey:key) };old["version"]=1
        let restored=try BackupCodec.decode(JSONSerialization.data(withJSONObject:old))
        XCTAssertEqual(restored.version,2);XCTAssertEqual(restored.readings,data.readings);XCTAssertTrue(restored.sourceLinks.isEmpty)
        let envelope:[String:Any] = ["format":"mihen.archive","archiveVersion":1,"document":old]
        XCTAssertEqual(try BackupArchive.decode(JSONSerialization.data(withJSONObject:envelope)).archiveVersion,2)
        old["version"]=2;XCTAssertThrowsError(try BackupCodec.decode(JSONSerialization.data(withJSONObject:old)))
        var linked=data;try linked.connectSource("reading:r",to:linked.occurrences[0].id,engine:engine)
        XCTAssertEqual(try BackupCodec.decode(BackupCodec.encode(linked)).sourceLinks,linked.sourceLinks)
        XCTAssertEqual(try BackupCodec.importCSV(BackupCodec.exportCSV(linked)).sourceLinks,linked.sourceLinks)
    }
}
