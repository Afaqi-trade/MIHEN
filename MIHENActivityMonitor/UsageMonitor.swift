import DeviceActivity
import OSLog

final class UsageMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        perform { try UsageLimitRuntime.reconcile() }
    }
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        guard event.rawValue == "dailyLimit" else { return }
        perform { try UsageLimitRuntime.threshold(activity: activity) }
    }
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        perform { try UsageLimitRuntime.intervalEnded(activity: activity) }
    }
    private func perform(_ operation: () throws -> Void) {
        do { try operation() }
        catch { Logger(subsystem: "com.example.mihen", category: "UsageMonitor").error("Usage limit state could not be reconciled; existing shield retained.") }
    }
}
