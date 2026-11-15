import Foundation
import Observation
import FamilyControls
import DeviceActivity

@MainActor @Observable final class ScreenTimeController {
    var document = UsageLimitDocument()
    var errorKey: String?
    var busy = false
    var loaded = false
    var authorized: Bool { AuthorizationCenter.shared.authorizationStatus == .approved }
    var blocked: Bool { document.policy.shouldShield(at: Date(), calendar: .current) }
    func refresh() {
        do {
            let repository = try UsageLimitRepository.shared()
            document = try repository.read()
            if !authorized && document.policy.enabled {
                try Self.reset()
                document = try repository.read()
            } else if authorized {
                if document.policy.enabled && !DeviceActivityCenter().activities.contains(UsageLimitRuntime.dailyName(document.policy.revision)) {
                    try Self.reset()
                    document = try repository.read()
                    loaded = true; errorKey = "screen.monitor.lost"
                    return
                }
                try UsageLimitRuntime.reconcile()
                document = try repository.read()
            }
            loaded = true; errorKey = nil
        } catch { loaded = false; report(error) }
    }
    func authorize() async {
        busy = true; defer { busy = false }
        do { try await AuthorizationCenter.shared.requestAuthorization(for: .individual); refresh() }
        catch { report(error) }
    }
    func enable(selection: FamilyActivitySelection, minutes: Int) {
        guard authorized, (1...720).contains(minutes),
              !(selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty && selection.webDomainTokens.isEmpty) else { errorKey = "screen.invalid"; return }
        do {
            let repository = try UsageLimitRepository.shared()
            guard !(try repository.read()).policy.enabled else { throw PlanError.invalid("screen.disable.first") }
            var candidate = UsageLimitDocument()
            candidate.selection = selection
            candidate.policy = .init(enabled: true, minutes: minutes)
            try repository.update { $0 = candidate }
            do {
                let schedule = DeviceActivitySchedule(intervalStart: DateComponents(hour: 0, minute: 0), intervalEnd: DateComponents(hour: 23, minute: 59, second: 59), repeats: true)
                let event = DeviceActivityEvent(applications: selection.applicationTokens, categories: selection.categoryTokens, webDomains: selection.webDomainTokens, threshold: DateComponents(minute: minutes), includesPastActivity: true)
                try DeviceActivityCenter().startMonitoring(UsageLimitRuntime.dailyName(candidate.policy.revision), during: schedule, events: [.init("dailyLimit"): event])
            } catch {
                try Self.reset()
                throw error
            }
            refresh()
        } catch { report(error) }
    }
    func temporarilyOpen(minutes: Int, reason: String) async {
        guard !busy else { return }
        busy = true; defer { busy = false }
        do {
            guard authorized, try await AppLock.authenticate(reason: reason) else { throw PlanError.invalid("screen.approval.required") }
            let repository = try UsageLimitRepository.shared()
            let before = try repository.read()
            var policy = before.policy
            let now = Date(), id = UUID().uuidString
            try policy.grantTemporary(minutes: minutes, id: id, at: now, calendar: .current)
            let end = Date(timeIntervalSince1970: ceil(policy.temporaryUntil!.timeIntervalSince1970))
            policy.temporaryUntil = end
            let calendar = Calendar.current
            let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
            var startParts = calendar.dateComponents(components, from: now)
            var endParts = calendar.dateComponents(components, from: end)
            startParts.calendar = calendar; endParts.calendar = calendar
            startParts.timeZone = calendar.timeZone; endParts.timeZone = calendar.timeZone
            // Arm the expiry monitor BEFORE removing shields. Never promise a timer without it.
            let center = DeviceActivityCenter()
            center.stopMonitoring(center.activities.filter { $0.rawValue.hasPrefix(UsageLimitRuntime.prefix + "temporary.") })
            try center.startMonitoring(UsageLimitRuntime.temporaryName(id), during: DeviceActivitySchedule(intervalStart: startParts, intervalEnd: endParts, repeats: false))
            do {
                try repository.update({ state in
                    guard state.policy.enabled, state.policy.revision == before.policy.revision else { throw PlanError.invalid("screen.changed") }
                    try state.policy.grantTemporary(minutes: minutes, id: id, at: now, calendar: .current)
                    state.policy.temporaryUntil = end
                }, afterCommit: { UsageLimitRuntime.apply($0) })
            } catch {
                DeviceActivityCenter().stopMonitoring([UsageLimitRuntime.temporaryName(id)])
                throw error
            }
            refresh()
        } catch { report(error) }
    }
    func disable(reason: String) async {
        guard !busy else { return }
        busy = true; defer { busy = false }
        do {
            guard try await AppLock.authenticate(reason: reason) else { throw PlanError.invalid("screen.approval.required") }
            try Self.reset(); refresh()
        } catch { report(error) }
    }
    static func reset() throws {
        // Persist disabled state first, so in-flight extension callbacks cannot reapply a shield.
        if let repository = try? UsageLimitRepository.shared() {
            try repository.reset(afterCommit: { UsageLimitRuntime.apply($0) })
        }
        UsageLimitRuntime.stopOwnMonitoring()
        UsageLimitRuntime.settings().clearAllSettings()
    }
    static func reconcileOnForeground() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--ui-testing") { return }
        #endif
        guard AuthorizationCenter.shared.authorizationStatus == .approved else { try? reset(); return }
        try? UsageLimitRuntime.reconcile()
    }
    private func report(_ error: Error) { errorKey = (error as? PlanError)?.errorDescription ?? "screen.system.error" }
}
