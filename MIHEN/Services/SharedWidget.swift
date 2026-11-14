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
