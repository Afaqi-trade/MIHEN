import XCTest
import Foundation
@testable import MIHEN

@MainActor final class ReportPerformanceTests: XCTestCase {
    func testNativeStoreAndExecutiveReportAtOneThreeAndTenYears() throws {
        let engine=PlanningEngine(timeZone:TimeZone(identifier:"Europe/Istanbul")!)
        let end=engine.date("2026-11-17")!
        var measurements=[[String:Double]]()
        for years in [1,3,10] {
            let start=engine.calendar.date(byAdding:.year,value:-years,to:end)!
            var fixture=BackupDocument.fresh()
            for index in 0..<3 { fixture.tasks.append(.init(id:"fixture-\(index)",title:"Synthetic performance fixture",domainID:"learning",start:start,recurrence:"daily",target:2,unit:"count")) }
            let days=engine.days(from:start,through:end)
            for day in days {
                let key=engine.key(day)
                for index in 0..<3 {
                    fixture.occurrences.append(.init(id:"\(key)-\(index)",taskID:"fixture-\(index)",day:key,title:"Synthetic performance fixture",domainID:"learning",target:2,unit:"count",value:index == 0 ? 2 : index == 1 ? 1 : 0,status:index == 0 ? "completed" : index == 1 ? "partial" : "planned"))
                }
                fixture.activities.append(.init(domainID:"health",date:day,kind:"water",amount:250,unit:"ml"))
            }
            let folder=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)
            defer { try? FileManager.default.removeItem(at:folder) }
            let url=folder.appendingPathComponent("synthetic.store")
            let clock=ProcessInfo.processInfo
            var tick=clock.systemUptime
            let repository=try Repository(storeURL:url)
            try repository.save(fixture)
            let save=clock.systemUptime-tick
            tick=clock.systemUptime
            let loaded=try Repository(storeURL:url).load()
            let load=clock.systemUptime-tick
            XCTAssertEqual(loaded.occurrences.count,days.count*3)
            tick=clock.systemUptime
            let interval=DateInterval(start:start,end:engine.addingDays(1,to:end))
            let report=engine.executiveReport(loaded,interval:interval,period:"report.tenYears",now:end)
            let analysis=clock.systemUptime-tick
            XCTAssertEqual(report.analysis.current.completed,days.count)
            XCTAssertEqual(report.analysis.current.partial,days.count)
            XCTAssertEqual(report.analysis.current.recordedDays.count,days.count)
            XCTAssertEqual(report.areas.count,8)
            measurements.append(["years":Double(years),"occurrences":Double(loaded.occurrences.count),"activities":Double(loaded.activities.count),"storeSaveSeconds":save,"storeReopenLoadSeconds":load,"executiveReportSeconds":analysis])
        }
        let attachment=XCTAttachment(data:try JSONSerialization.data(withJSONObject:measurements,options:[.prettyPrinted,.sortedKeys]),uniformTypeIdentifier:"public.json")
        attachment.name="MIHEN-Native-Performance-1-3-10-Years";attachment.lifetime = .keepAlways;add(attachment)
    }
}
