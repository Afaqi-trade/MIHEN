import Foundation

/// Approximate city centres for offline selection. Manual coordinates remain available.
public struct PrayerCity: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let zone: String
    public static let all: [PrayerCity] = [
        .init(id:"istanbul",name:"İstanbul",country:"Türkiye",latitude:41.0082,longitude:28.9784,zone:"Europe/Istanbul"),
        .init(id:"ankara",name:"Ankara",country:"Türkiye",latitude:39.9334,longitude:32.8597,zone:"Europe/Istanbul"),
        .init(id:"izmir",name:"İzmir",country:"Türkiye",latitude:38.4237,longitude:27.1428,zone:"Europe/Istanbul"),
        .init(id:"bursa",name:"Bursa",country:"Türkiye",latitude:40.1950,longitude:29.0600,zone:"Europe/Istanbul"),
        .init(id:"antalya",name:"Antalya",country:"Türkiye",latitude:36.8969,longitude:30.7133,zone:"Europe/Istanbul"),
        .init(id:"konya",name:"Konya",country:"Türkiye",latitude:37.8746,longitude:32.4932,zone:"Europe/Istanbul"),
        .init(id:"gaziantep",name:"Gaziantep",country:"Türkiye",latitude:37.0662,longitude:37.3833,zone:"Europe/Istanbul"),
        .init(id:"diyarbakir",name:"Diyarbakır",country:"Türkiye",latitude:37.9144,longitude:40.2306,zone:"Europe/Istanbul"),
        .init(id:"samsun",name:"Samsun",country:"Türkiye",latitude:41.2867,longitude:36.3300,zone:"Europe/Istanbul"),
        .init(id:"trabzon",name:"Trabzon",country:"Türkiye",latitude:41.0027,longitude:39.7168,zone:"Europe/Istanbul"),
        .init(id:"berlin",name:"Berlin",country:"Deutschland",latitude:52.5200,longitude:13.4050,zone:"Europe/Berlin"),
        .init(id:"london",name:"London",country:"United Kingdom",latitude:51.5074,longitude:-0.1278,zone:"Europe/London"),
        .init(id:"paris",name:"Paris",country:"France",latitude:48.8566,longitude:2.3522,zone:"Europe/Paris"),
        .init(id:"newyork",name:"New York",country:"United States",latitude:40.7128,longitude:-74.0060,zone:"America/New_York"),
        .init(id:"mecca",name:"Makkah / Mekke",country:"Saudi Arabia",latitude:21.4225,longitude:39.8262,zone:"Asia/Riyadh"),
        .init(id:"medina",name:"Madinah / Medine",country:"Saudi Arabia",latitude:24.4672,longitude:39.6111,zone:"Asia/Riyadh"),
        .init(id:"dubai",name:"Dubai",country:"United Arab Emirates",latitude:25.2048,longitude:55.2708,zone:"Asia/Dubai"),
        .init(id:"kualalumpur",name:"Kuala Lumpur",country:"Malaysia",latitude:3.1390,longitude:101.6869,zone:"Asia/Kuala_Lumpur"),
        .init(id:"sydney",name:"Sydney",country:"Australia",latitude:-33.8688,longitude:151.2093,zone:"Australia/Sydney")]
    public static func match(latitude: Double, longitude: Double, zone: String) -> PrayerCity? {
        all.first { abs($0.latitude-latitude)<0.00001 && abs($0.longitude-longitude)<0.00001 && $0.zone == zone }
    }
}
