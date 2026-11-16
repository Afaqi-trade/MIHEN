import XCTest
@testable import MIHENCore

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
