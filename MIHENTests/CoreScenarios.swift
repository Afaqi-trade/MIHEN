// Generated from Tests/MIHENCoreTests.
import XCTest
@testable import MIHEN

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
        for area in LifeArea.allCases {
            for label in area.legacyTitles + [area.titleTR, area.titleEN] {
                let oldRows = [PlanCSV.header, ["task", "legacy-id", "Test", label, "1", "count", "2024-01-01", "2024-12-31", "none"]]
                let oldPreview = try PlanCSV.preview(CSV.encode(oldRows), into: .fresh(), engine: engine)
                XCTAssertEqual(oldPreview.tasks.first?.domainID, area.rawValue)
            }
        }
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

import XCTest
@testable import MIHEN
final class GuidedTemplateTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
    func testWeekPreviewIsReadOnlyAndExcludesAlreadyLoadedTemplates() throws {
        var data=BackupDocument.fresh();let start=engine.date("2026-11-17")!
        let preview=engine.starterPreview(["template.movement","template.family"],from:start,in:data)
        XCTAssertEqual(preview.count,7);XCTAssertEqual(preview.reduce(0) { $0+$1.items.count },14)
        XCTAssertTrue(data.tasks.isEmpty);XCTAssertTrue(data.occurrences.isEmpty)
        data.addSelectedTemplates(["template.movement"],on:start,engine:engine)
        XCTAssertEqual(engine.starterPreview(["template.movement","template.family"],from:start,in:data)[0].items.count,1)
    }
    func testEveryAreaExampleCreatesOnlyAnExplicitEditablePlan() throws {
        var data=BackupDocument.fresh();let date=engine.date("2026-11-17")!
        for template in GuidedTemplate.choices {
            try data.applyGuidedTemplate(template,from:date,goalTitle:"Outcome",taskTitle:"Supporting step",milestoneTitle:"Review",engine:engine)
            try data.applyGuidedTemplate(template,from:date,goalTitle:"Duplicate",taskTitle:"Duplicate",milestoneTitle:"Duplicate",engine:engine)
        }
        XCTAssertEqual(data.goals.count,8);XCTAssertEqual(data.tasks.count,8);XCTAssertEqual(data.milestones.count,8)
        XCTAssertEqual(data.goalSupports.count,8);XCTAssertTrue(data.goalProgress.isEmpty)
        XCTAssertTrue(data.occurrences.allSatisfy { $0.value == 0 && $0.status == "planned" && $0.day >= "2026-11-17" })
        XCTAssertTrue(data.tasks.allSatisfy { $0.goalID == nil && $0.notes.isEmpty })
        XCTAssertTrue(data.milestones.allSatisfy { !$0.done })
        XCTAssertEqual(try BackupCodec.decode(BackupCodec.encode(data)).goals,data.goals)
    }
    func testCitySelectionHasValidTimeZonesAndIstanbulRemainsDefault() throws {
        XCTAssertEqual(PrayerCity.all.first?.id,"istanbul")
        for city in PrayerCity.all {
            XCTAssertTrue(TimeZone(identifier:city.zone) != nil)
            XCTAssertEqual(PrayerCity.match(latitude:city.latitude,longitude:city.longitude,zone:city.zone)?.id,city.id)
            XCTAssertTrue((-90...90).contains(city.latitude) && (-180...180).contains(city.longitude))
        }
        XCTAssertNil(PrayerCity.match(latitude:0,longitude:0,zone:"UTC"))
    }
}

import XCTest
@testable import MIHEN

final class NutritionPlanningTests: XCTestCase {
    let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
    func testPlanNeverCreatesActualNutritionAndEditingDoesNotDuplicate() throws {
        var data=BackupDocument.fresh();let day=engine.date("2026-11-16")!
        try data.saveNutritionPlan(.init(date:day,kind:"food",amount:500,unit:"kcal",meal:"lunch",title:"Lunch"))
        XCTAssertEqual(data.nutritionTotal("food",on:day,engine:engine,planned:true),500)
        XCTAssertEqual(data.nutritionTotal("food",on:day,engine:engine),0)
        let id=try data.saveNutrition(date:day,kind:"food",amount:450,meal:"lunch",title:"Soup",note:"",engine:engine,recordedAt:day)
        try data.saveNutrition(id:id,date:day,kind:"food",amount:400,meal:"lunch",title:"Soup",note:"Edited",engine:engine,recordedAt:engine.addingDays(1,to:day))
        XCTAssertEqual(data.activities.count,1);XCTAssertEqual(data.activityAnnotations.count,1)
        XCTAssertEqual(data.nutritionTotal("food",on:day,engine:engine),400)
        XCTAssertEqual(data.activityAnnotations.first?.meal,"lunch")
        XCTAssertEqual(try BackupCodec.decode(BackupCodec.encode(data)).nutritionPlans,data.nutritionPlans)
    }
    func testNutritionEditUpdatesItsLinkedTaskWithoutAddingASecondEntry() throws {
        var data=BackupDocument.fresh();let day=engine.date("2026-11-16")!
        data.tasks=[.init(id:"t",title:"Water",domainID:"health",start:day,target:1000,unit:"ml")]
        engine.materialize(&data,from:day,through:day)
        let id=try data.saveNutrition(date:day,kind:"water",amount:250,meal:"other",title:"",note:"",engine:engine)
        try data.connectSource("activity:"+id,to:data.occurrences[0].id,engine:engine)
        try data.saveNutrition(id:id,date:day,kind:"water",amount:500,meal:"other",title:"",note:"",engine:engine)
        XCTAssertEqual(data.occurrences[0].value,500);XCTAssertEqual(data.activities.count,1)
        XCTAssertThrowsError(try data.saveNutrition(id:id,date:engine.addingDays(1,to:day),kind:"water",amount:500,meal:"other",title:"",note:"",engine:engine))
        XCTAssertEqual(data.activities[0].date,day)
    }
    func testQuickWaterOptionsAreValidatedAndHealthSourceIsReadOnly() throws {
        var data=BackupDocument.fresh()
        XCTAssertEqual(data.waterShortcuts,[250,500])
        data.setOption("water.quick",value:"200,350,500");try BackupCodec.validate(data)
        XCTAssertEqual(data.waterShortcuts,[200,350,500])
        var bad=data;bad.setOption("water.quick",value:"200,200");XCTAssertThrowsError(try BackupCodec.validate(bad))
        bad=data;bad.setOption("water.quick",value:"-1,500");XCTAssertThrowsError(try BackupCodec.validate(bad))
        XCTAssertThrowsError(try data.saveNutrition(id:"health.energy:2026-11-16",date:Date(),kind:"energyBurned",amount:5,meal:"other",title:"",note:"",engine:engine))
    }
}

import XCTest
@testable import MIHEN
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

extension PeriodReportTests {
    func testTenYearReportWithOverTenThousandSyntheticOccurrences() throws {
        var data=BackupDocument.fresh();let start=engine.date("2016-01-01")!,end=engine.date("2026-01-01")!
        let dates=engine.days(from:start,through:engine.addingDays(-1,to:end))
        data.tasks=(0..<3).map { .init(id:"stress-task-\($0)",title:"Synthetic fixture",domainID:"health",start:start,recurrence:"daily") }
        for (index,date) in dates.enumerated() {
            for task in data.tasks {
                let done=(index + (task.id.hasSuffix("1") ? 1 : 0)) % 2 == 0
                data.occurrences.append(.init(taskID:task.id,day:engine.key(date),title:task.title,domainID:task.domainID,value:done ? 1 : 0,status:done ? "completed" : "planned"))
            }
        }
        try BackupCodec.validate(data)
        let clock=Date()
        let result=engine.periodReport(data,in:DateInterval(start:engine.calendar.startOfDay(for:start),end:engine.calendar.startOfDay(for:end)))
        print("Synthetic Core ten-year report: \(data.occurrences.count) occurrences, \(Date().timeIntervalSince(clock) * 1000) ms")
        XCTAssertTrue(data.occurrences.count > 10_000)
        XCTAssertEqual(result.planned,data.occurrences.count)
        XCTAssertEqual(result.recordedDays.count,dates.count)
    }
}

import XCTest
@testable import MIHEN

final class PlanningTests: XCTestCase {
    func testUpcomingRecurringEventUsesNextOccurrence() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let start = engine.date("2026-11-01")!
        let today = engine.date("2026-11-14")!
        let event = CalendarEventRecord(title: "Weekly", date: start, end: start, recurrence: "weekly")
        let result = engine.upcomingEvents([event], after: today)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(engine.key(result[0].next), "2026-11-15")
        XCTAssertTrue(engine.upcomingEvents([CalendarEventRecord(title: "Past", date: start, end: start)], after: today).isEmpty)
    }

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

    func testEditingStarterNameAndNotesDoesNotDuplicateOrLeakMetadata() {
        var data = BackupDocument.fresh()
        data.addStarterTemplates(on: date("2024-01-01"), engine: engine)
        XCTAssertTrue(data.tasks.allSatisfy { $0.notes.isEmpty })
        data.tasks[0].title = "Kendi başlığım"
        data.tasks[0].notes = "Kişisel notum"
        data.addStarterTemplates(on: date("2024-01-02"), engine: engine)
        XCTAssertEqual(data.tasks.count, 8)
        XCTAssertEqual(data.tasks[0].title, "Kendi başlığım")
        XCTAssertEqual(data.tasks[0].notes, "Kişisel notum")
    }

}

import XCTest
@testable import MIHEN

final class PrayerTests: XCTestCase {
    func testWidgetTimelineUsesPrayerTimeZoneAndCalendarMidnight() throws {
        let london = PrayerSettings(latitude: 51.5074, longitude: -0.1278, timeZoneID: "Europe/London", method: "turkey", hanafi: false)
        let now = ISO8601DateFormatter().date(from: "2026-03-29T00:15:00Z")!
        let tomorrow = ISO8601DateFormatter().date(from: "2026-03-29T23:00:00Z")!
        let dates = london.widgetTimelineDates(from: now)
        XCTAssertEqual(dates.first, now)
        XCTAssertEqual(dates.last, tomorrow)
        XCTAssertEqual(dates, dates.sorted())
        XCTAssertTrue(london.schedule(on: now).allSatisfy { dates.contains($0.date) })
        var invalid = london
        invalid.timeZoneID = "invalid/zone"
        XCTAssertEqual(invalid.widgetTimelineDates(from: now), [now])
    }
    func testIstanbulNovember2026AgainstPublishedCalendarSample() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let date = engine.date("2026-11-15")!
        let settings = PrayerSettings(latitude: 41.0082, longitude: 28.9784, timeZoneID: "Europe/Istanbul", method: "turkey", hanafi: false)
        // Published third-party calendar sample, not a Diyanet feed or proof for other dates.
        // https://www.turkgun.com/uploads/1794696307-pdf-turkgun-gazetesi-15-kasim-2026.pdf
        let reference = [(6,16),(7,44),(12,54),(15,29),(17,53),(19,16)]
        let actual = settings.schedule(on: date)
        XCTAssertEqual(actual.count, reference.count)
        for (index, item) in actual.enumerated() {
            let expected = engine.calendar.date(bySettingHour: reference[index].0, minute: reference[index].1, second: 0, of: date)!
            XCTAssertTrue(abs(item.date.timeIntervalSince(expected)) <= 120)
        }
    }
    func testAnkaraReferenceAndMadhabDifference() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let day = engine.date("2019-01-01")!
        var settings = PrayerSettings(latitude: 39.939382, longitude: 32.819713, timeZoneID: "Europe/Istanbul", method: "turkey", hanafi: false)
        let standard = settings.schedule(on: day)
        XCTAssertEqual(standard.count, 6)
        XCTAssertEqual(settings.displayTime(ISO8601DateFormatter().date(from: "2026-11-15T00:00:00Z")!), "03:00")
        // Adhan upstream Ankara fixture: Jan 1 2019, 06:33 / 08:03 / 12:57 / 15:20 / 17:40 / 19:05, tolerance 2 minutes.
        let expected = [(6,33),(8,3),(12,57),(15,20),(17,40),(19,5)]
        for (index, item) in standard.enumerated() {
            let reference = engine.calendar.date(bySettingHour: expected[index].0, minute: expected[index].1, second: 0, of: day)!
            XCTAssertTrue(abs(reference.timeIntervalSince(item.date)) <= 120)
        }
        settings.hanafi = true
        XCTAssertTrue(settings.schedule(on: day)[3].date > standard[3].date)
        settings.latitude = 91
        XCTAssertTrue(settings.schedule(on: day).isEmpty)
    }
}

import XCTest
@testable import MIHEN

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

import XCTest
@testable import MIHEN

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

import XCTest
@testable import MIHEN

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

import XCTest
@testable import MIHEN

final class UsageLimitTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        return calendar
    }
    private var now: Date { ISO8601DateFormatter().date(from: "2026-11-15T10:00:00Z")! }
    func testTemporaryScheduleUsesAbsoluteTimeAcrossRepeatedLocalHour() throws {
        let start = ISO8601DateFormatter().date(from: "2026-11-01T05:50:00Z")!
        let end = start.addingTimeInterval(1800)
        let interval = UsageLimitPolicy.absoluteSchedule(start: start, end: end)
        XCTAssertEqual(interval.start.date, start)
        XCTAssertEqual(interval.end.date, end)
        XCTAssertEqual(interval.start.timeZone?.secondsFromGMT(), 0)
        XCTAssertEqual(interval.end.timeZone?.secondsFromGMT(), 0)
        XCTAssertEqual(interval.end.date!.timeIntervalSince(interval.start.date!), 1800)
    }
    func testThresholdOnlyAffectsCurrentEnabledRevision() {
        var policy = UsageLimitPolicy(revision: "current", enabled: true)
        policy.reachedThreshold(revision: "old", at: now, calendar: calendar)
        XCTAssertFalse(policy.shouldShield(at: now, calendar: calendar))
        policy.reachedThreshold(revision: "current", at: now, calendar: calendar)
        XCTAssertTrue(policy.shouldShield(at: now, calendar: calendar))
        policy.enabled = false
        policy.reachedThreshold(revision: "current", at: now, calendar: calendar)
        XCTAssertFalse(policy.shouldShield(at: now, calendar: calendar))
    }
    func testTemporaryUnlockExpiresAndRepeatedThresholdDoesNotEndIt() throws {
        var policy = UsageLimitPolicy(revision: "current", enabled: true)
        policy.reachedThreshold(revision: "current", at: now, calendar: calendar)
        try policy.grantTemporary(minutes: 15, id: "grant", at: now, calendar: calendar)
        XCTAssertFalse(policy.shouldShield(at: now.addingTimeInterval(899), calendar: calendar))
        policy.reachedThreshold(revision: "current", at: now.addingTimeInterval(30), calendar: calendar)
        XCTAssertFalse(policy.shouldShield(at: now.addingTimeInterval(30), calendar: calendar))
        policy.endTemporary(id: "old", at: now.addingTimeInterval(901))
        XCTAssertEqual(policy.temporaryID, "grant")
        XCTAssertTrue(policy.shouldShield(at: now.addingTimeInterval(900), calendar: calendar))
        policy.endTemporary(id: "grant", at: now.addingTimeInterval(900))
        XCTAssertNil(policy.temporaryUntil)
        XCTAssertTrue(policy.shouldShield(at: now.addingTimeInterval(900), calendar: calendar))
    }
    func testOldExpiryCannotCancelASecondApprovedGrant() throws {
        var policy = UsageLimitPolicy(enabled: true)
        policy.reachedThreshold(revision: policy.revision, at: now, calendar: calendar)
        try policy.grantTemporary(minutes: 15, id: "old", at: now, calendar: calendar)
        let later = now.addingTimeInterval(901)
        try policy.grantTemporary(minutes: 30, id: "new", at: later, calendar: calendar)
        policy.endTemporary(id: "old", at: later)
        XCTAssertEqual(policy.temporaryID, "new")
        XCTAssertFalse(policy.shouldShield(at: later, calendar: calendar))
        XCTAssertTrue(policy.shouldShield(at: later.addingTimeInterval(1800), calendar: calendar))
    }
    func testMidnightResetsBudgetWithoutLosingActiveGrant() throws {
        let late = ISO8601DateFormatter().date(from: "2026-11-15T20:55:00Z")!
        var policy = UsageLimitPolicy(revision: "current", enabled: true)
        policy.reachedThreshold(revision: "current", at: late, calendar: calendar)
        try policy.grantTemporary(minutes: 15, id: "grant", at: late, calendar: calendar)
        let next = calendar.date(byAdding: .minute, value: 10, to: late)!
        policy.reconcile(at: next, calendar: calendar)
        XCTAssertNil(policy.exceededDay)
        XCTAssertEqual(policy.temporaryID, "grant")
        XCTAssertFalse(policy.shouldShield(at: next, calendar: calendar))
        policy.reachedThreshold(revision: "current", at: next, calendar: calendar)
        XCTAssertFalse(policy.shouldShield(at: next, calendar: calendar))
        XCTAssertTrue(policy.shouldShield(at: late.addingTimeInterval(900), calendar: calendar))
    }
    func testApprovalCannotOpenAnUnblockedOrDisabledPolicy() {
        var policy = UsageLimitPolicy(enabled: true)
        XCTAssertThrowsError(try policy.grantTemporary(minutes: 15, id: "grant", at: now, calendar: calendar))
        policy.reachedThreshold(revision: policy.revision, at: now, calendar: calendar)
        XCTAssertThrowsError(try policy.grantTemporary(minutes: 5, id: "grant", at: now, calendar: calendar))
        policy.enabled = false
        XCTAssertThrowsError(try policy.grantTemporary(minutes: 15, id: "grant", at: now, calendar: calendar))
    }
    func testGrantSurvivesRelaunchAndDayUsesCalendarAcrossDST() throws {
        var policy = UsageLimitPolicy(enabled: true)
        policy.reachedThreshold(revision: policy.revision, at: now, calendar: calendar)
        try policy.grantTemporary(minutes: 30, id: "grant", at: now, calendar: calendar)
        let loaded = try JSONDecoder().decode(UsageLimitPolicy.self, from: JSONEncoder().encode(policy))
        XCTAssertEqual(loaded, policy)
        var newYork = calendar; newYork.timeZone = TimeZone(identifier: "America/New_York")!
        let first = ISO8601DateFormatter().date(from: "2026-11-01T05:30:00Z")!
        let second = ISO8601DateFormatter().date(from: "2026-11-01T06:30:00Z")!
        XCTAssertEqual(UsageLimitPolicy.day(first, calendar: newYork), UsageLimitPolicy.day(second, calendar: newYork))
    }
}
