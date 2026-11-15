import Foundation
import ManagedSettings
import DeviceActivity

/// Shared by the main app and monitor extension. No simulated enforcement path.
enum UsageLimitRuntime {
    static let prefix = "mihen.usage."
    static func dailyName(_ revision: String) -> DeviceActivityName { .init(prefix + "daily." + revision) }
    static func temporaryName(_ id: String) -> DeviceActivityName { .init(prefix + "temporary." + id) }
    static func settings() -> ManagedSettingsStore { ManagedSettingsStore(named: .init("mihen.usage")) }
    static func apply(_ document: UsageLimitDocument, now: Date = Date()) {
        let store = settings()
        if document.policy.shouldShield(at: now, calendar: .current) {
            store.shield.applications = document.selection.applicationTokens.isEmpty ? nil : document.selection.applicationTokens
            store.shield.webDomains = document.selection.webDomainTokens.isEmpty ? nil : document.selection.webDomainTokens
            store.shield.applicationCategories = document.selection.categoryTokens.isEmpty ? nil : .specific(document.selection.categoryTokens)
            store.shield.webDomainCategories = document.selection.categoryTokens.isEmpty ? nil : .specific(document.selection.categoryTokens)
        } else { store.clearAllSettings() }
    }
    static func reconcile() throws {
        try UsageLimitRepository.shared().update({ $0.policy.reconcile(at: Date(), calendar: .current) }, afterCommit: { apply($0) })
    }
    static func threshold(activity: DeviceActivityName) throws {
        let now = Date()
        try UsageLimitRepository.shared().update({ document in
            guard activity == dailyName(document.policy.revision) else { return }
            document.policy.reachedThreshold(revision: document.policy.revision, at: now, calendar: .current)
        }, afterCommit: { apply($0, now: now) })
    }
    static func intervalEnded(activity: DeviceActivityName) throws {
        let now = Date()
        try UsageLimitRepository.shared().update({ document in
            if let id = document.policy.temporaryID, activity == temporaryName(id) { document.policy.endTemporary(id: id, at: now) }
            document.policy.reconcile(at: now, calendar: .current)
        }, afterCommit: { apply($0, now: now) })
    }
    static func stopOwnMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring(center.activities.filter { $0.rawValue.hasPrefix(prefix) })
    }
}
