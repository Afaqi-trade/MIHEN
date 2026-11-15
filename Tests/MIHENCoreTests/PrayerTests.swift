import XCTest
@testable import MIHENCore

final class PrayerTests: XCTestCase {
    func testAnkaraReferenceAndMadhabDifference() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        let day = engine.date("2019-01-01")!
        var settings = PrayerSettings(latitude: 39.939382, longitude: 32.819713, timeZoneID: "Europe/Istanbul", method: "turkey", hanafi: false)
        let standard = settings.schedule(on: day)
        XCTAssertEqual(standard.count, 6)
        XCTAssertEqual(settings.displayTime(Date(timeIntervalSince1970: 0)), "03:00")
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
