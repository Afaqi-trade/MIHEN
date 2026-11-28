import XCTest
@testable import MIHENCore

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
    func testSummerAndSecondCityAgainstPublishedCalendarSamples() throws {
        let engine = PlanningEngine(timeZone: TimeZone(identifier: "Europe/Istanbul")!)
        // Independent published calendar samples; the comparison does not establish official status.
        let samples: [(Double, Double, String, [(Int, Int)])] = [
            (41.0082, 28.9784, "2026-06-15", [(3,24),(5,24),(13,10),(17,9),(20,45),(22,36)]),
            (38.4237, 27.1428, "2026-11-15", [(6,21),(7,46),(13,1),(15,43),(18,6),(19,26)])
        ]
        for (latitude, longitude, day, reference) in samples {
            let date = engine.date(day)!
            let settings = PrayerSettings(latitude: latitude, longitude: longitude, timeZoneID: "Europe/Istanbul", method: "turkey", hanafi: false)
            let actual = settings.schedule(on: date)
            XCTAssertEqual(actual.count, reference.count)
            for (index, item) in actual.enumerated() {
                let expected = engine.calendar.date(bySettingHour: reference[index].0, minute: reference[index].1, second: 0, of: date)!
                XCTAssertTrue(abs(item.date.timeIntervalSince(expected)) <= 120)
            }
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
