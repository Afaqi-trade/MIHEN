import XCTest
@testable import MIHENCore
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
