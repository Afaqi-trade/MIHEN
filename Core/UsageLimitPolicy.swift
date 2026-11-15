import Foundation

/// Enforcement state only. Application tokens belong to the platform adapter.
public struct UsageLimitPolicy: Codable, Equatable, Sendable {
    public var revision: String
    public var enabled: Bool
    public var minutes: Int
    public var exceededDay: String?
    public var temporaryUntil: Date?
    public var temporaryID: String?
    public init(revision: String = UUID().uuidString, enabled: Bool = false, minutes: Int = 60) {
        self.revision = revision; self.enabled = enabled; self.minutes = minutes
    }
    public static func day(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }
    public func shouldShield(at now: Date, calendar: Calendar) -> Bool {
        enabled && exceededDay == Self.day(now, calendar: calendar) && !(temporaryUntil.map { $0 > now } ?? false)
    }
    public mutating func reachedThreshold(revision: String, at now: Date, calendar: Calendar) {
        guard enabled, self.revision == revision else { return }
        exceededDay = Self.day(now, calendar: calendar)
    }
    public mutating func grantTemporary(minutes: Int, id: String, at now: Date, calendar: Calendar) throws {
        guard [15, 30, 60].contains(minutes), shouldShield(at: now, calendar: calendar) else { throw PlanError.invalid("screen.invalid") }
        temporaryID = id
        temporaryUntil = now.addingTimeInterval(Double(minutes) * 60)
    }
    public mutating func endTemporary(id: String, at now: Date) {
        guard temporaryID == id, let until = temporaryUntil, now >= until else { return }
        temporaryUntil = nil; temporaryID = nil
    }
    public mutating func reconcile(at now: Date, calendar: Calendar) {
        if exceededDay != Self.day(now, calendar: calendar) { exceededDay = nil }
        if let until = temporaryUntil, until <= now { temporaryUntil = nil; temporaryID = nil }
    }
}
