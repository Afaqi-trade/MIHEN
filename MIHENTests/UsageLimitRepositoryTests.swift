import XCTest
import FamilyControls
import DeviceActivity
@testable import MIHEN

final class UsageLimitRepositoryTests: XCTestCase {
    func testMonitorCallbackStateSurvivesRelaunchAndExpiresTemporaryGrant() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let repository = UsageLimitRepository(folder: folder)
        let now = Date()
        try repository.update { $0.policy = UsageLimitPolicy(revision: "current", enabled: true) }
        var shieldIntent = false
        let effect: (UsageLimitDocument, Date) -> Void = { state, date in shieldIntent = state.policy.shouldShield(at: date, calendar: .current) }
        try UsageLimitRuntime.threshold(activity: UsageLimitRuntime.dailyName("old"), repository: repository, now: now, effect: effect)
        XCTAssertFalse(shieldIntent)
        try UsageLimitRuntime.threshold(activity: UsageLimitRuntime.dailyName("current"), repository: repository, now: now, effect: effect)
        XCTAssertTrue(shieldIntent)
        try repository.update { try $0.policy.grantTemporary(minutes: 15, id: "approval", at: now, calendar: .current) }
        let reopened = UsageLimitRepository(folder: folder)
        XCTAssertFalse(try reopened.read().policy.shouldShield(at: now, calendar: .current))
        try UsageLimitRuntime.intervalEnded(activity: UsageLimitRuntime.temporaryName("approval"), repository: reopened, now: now.addingTimeInterval(900), effect: effect)
        XCTAssertTrue(shieldIntent)
        XCTAssertNil(try repository.read().policy.temporaryUntil)
        try repository.reset { _ in }
        try UsageLimitRuntime.threshold(activity: UsageLimitRuntime.dailyName("current"), repository: repository, now: now, effect: effect)
        XCTAssertFalse(shieldIntent)
    }

    func testConcurrentAppAndMonitorUpdatesAreNotLost() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let repository = UsageLimitRepository(folder: folder)
        try repository.update { $0.policy.minutes = 30 }
        DispatchQueue.concurrentPerform(iterations: 20) { _ in
            do { try UsageLimitRepository(folder: folder).update { $0.policy.minutes += 1 } }
            catch { XCTFail("Concurrent transaction failed") }
        }
        XCTAssertEqual(try repository.read().policy.minutes, 50)
    }

    func testIndependentWritersAndCorruptReset() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let first = UsageLimitRepository(folder: folder)
        let second = UsageLimitRepository(folder: folder)
        try first.update { $0.policy.minutes = 90 }
        try second.update { $0.policy.exceededDay = "2026-11-15" }
        XCTAssertEqual(try first.read().policy.minutes, 90)
        XCTAssertEqual(try first.read().policy.exceededDay, "2026-11-15")
        XCTAssertThrowsError(try first.update { $0.policy.minutes = 0 })
        XCTAssertEqual(try second.read().policy.minutes, 90)
        try Data("invalid".utf8).write(to: folder.appendingPathComponent("state.json"))
        XCTAssertThrowsError(try first.read())
        var effects = 0
        try second.reset { state in effects += 1; XCTAssertFalse(state.policy.enabled) }
        XCTAssertEqual(effects, 1)
        XCTAssertFalse(try first.read().policy.enabled)
        XCTAssertTrue(try first.read().selection.applicationTokens.isEmpty)
    }
    func testRejectedMutationDoesNotCommitOrApplyShieldEffect() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let repository = UsageLimitRepository(folder: folder)
        try repository.update { $0.policy.minutes = 45 }
        var effects = 0
        XCTAssertThrowsError(try repository.update({ state in
            state.policy.minutes = 20
            throw PlanError.invalid("screen.invalid")
        }, afterCommit: { _ in effects += 1 }))
        XCTAssertEqual(effects, 0)
        XCTAssertEqual(try repository.read().policy.minutes, 45)
    }
}
