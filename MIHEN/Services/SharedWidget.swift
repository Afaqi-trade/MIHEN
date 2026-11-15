import Foundation

struct WidgetSnapshot: Codable, Sendable {
    var day: String
    var timeZoneID: String
    var language: String
    var planned: Int
    var completed: Int
    var nextTitle: String?
    var locked: Bool
}
enum SharedWidgetStore {
    static var url: URL? {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "MihenAppGroup") as? String, !group.isEmpty else { return nil }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appendingPathComponent("today-widget.json")
    }
    static func write(_ snapshot: WidgetSnapshot) throws {
        guard let url else { throw PlanError.invalid("widget.unavailable") }
        let bytes = try JSONEncoder().encode(snapshot)
        try bytes.write(to: url, options: [.atomic, .completeFileProtection])
    }
    static func read() -> WidgetSnapshot? {
        guard let url, let bytes = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: bytes)
    }
}

enum PrayerSettingsStore {
    static var defaults: UserDefaults {
        if let group = Bundle.main.object(forInfoDictionaryKey: "MihenAppGroup") as? String,
           FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil,
           let shared = UserDefaults(suiteName: group) { return shared }
        return .standard
    }
    static func read() -> PrayerSettings? {
        guard let data = defaults.data(forKey: "prayer.settings.v1") else { return nil }
        return try? JSONDecoder().decode(PrayerSettings.self, from: data)
    }
    static func save(_ settings: PrayerSettings) throws {
        defaults.set(try JSONEncoder().encode(settings), forKey: "prayer.settings.v1")
    }
    static func clear() { defaults.removeObject(forKey: "prayer.settings.v1") }
}
