import XCTest
@testable import MIHENCore

final class UsageLimitTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Istanbul")!
        return calendar
    }
    private var now: Date { ISO8601DateFormatter().date(from: "2026-11-15T10:00:00Z")! }
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
