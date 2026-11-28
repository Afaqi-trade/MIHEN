import Foundation

public struct PrayerSettings: Codable, Equatable, Sendable {
    public var latitude: Double
    public var longitude: Double
    public var timeZoneID: String
    public var method: String
    public var hanafi: Bool
    public var highLatitude: String
    public init(latitude: Double, longitude: Double, timeZoneID: String, method: String, hanafi: Bool, highLatitude: String = "middleOfTheNight") {
        self.latitude = latitude; self.longitude = longitude; self.timeZoneID = timeZoneID
        self.method = method; self.hanafi = hanafi; self.highLatitude = highLatitude
    }
    public func displayTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: timeZoneID)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    /// Times at which today's widget content can change, including local midnight.
    public func widgetTimelineDates(from now: Date) -> [Date] {
        guard let zone = TimeZone(identifier: timeZoneID) else { return [now] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let start = calendar.startOfDay(for: now)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: start) else { return [now] }
        let changes = schedule(on: now).map(\.date).filter { $0 > now && $0 < tomorrow }
        return Array(Set([now, tomorrow] + changes)).sorted()
    }
    public func schedule(on date: Date) -> [(key: String, date: Date)] {
        guard latitude.isFinite, longitude.isFinite, abs(latitude) <= 90, abs(longitude) <= 180,
              let zone = TimeZone(identifier: timeZoneID), let method = CalculationMethod(rawValue: method), method != .other,
              let rule = HighLatitudeRule(rawValue: highLatitude) else { return [] }
        var calendar = Calendar(identifier: .gregorian); calendar.timeZone = zone
        var parameters = method.params
        parameters.madhab = hanafi ? .hanafi : .shafi
        parameters.highLatitudeRule = rule
        // Polar substitution is intentionally disabled: unavailable times remain unavailable.
        parameters.polarCircleResolution = .unresolved
        guard let times = PrayerTimes(coordinates: Coordinates(latitude: latitude, longitude: longitude), date: calendar.dateComponents([.year, .month, .day], from: date), calculationParameters: parameters) else { return [] }
        return [("fajr", times.fajr), ("sunrise", times.sunrise), ("dhuhr", times.dhuhr), ("asr", times.asr), ("maghrib", times.maghrib), ("isha", times.isha)]
    }
}
