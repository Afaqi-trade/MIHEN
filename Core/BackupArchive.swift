import Foundation

/// Versioned export envelope. The existing SwiftData V1 entities stay frozen; V2 adds independent records.
/// Legacy plain BackupDocument JSON is read without manufacturing missing settings.
public struct BackupArchive: Codable, Equatable, Sendable {
    public var format = "mihen.archive"
    public var archiveVersion = 2
    public var document: BackupDocument
    public var prayer: PrayerSettings?
    public init(document: BackupDocument, prayer: PrayerSettings? = nil) { self.document = document; self.prayer = prayer }
    public func encoded() throws -> Data {
        try validate()
        let bytes = try BackupCodec.encoder().encode(self)
        guard bytes.count <= BackupCodec.maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        return bytes
    }
    public static func decode(_ bytes: Data) throws -> BackupArchive {
        guard bytes.count <= BackupCodec.maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        let object = try JSONSerialization.jsonObject(with: bytes) as? [String: Any]
        if object?["format"] != nil {
            var archive = try BackupCodec.decoder().decode(Self.self, from: bytes)
            guard [1,2].contains(archive.archiveVersion) else { throw PlanError.invalid("validation.version") }
            archive.archiveVersion = 2
            try archive.validate(); return archive
        }
        return try .init(document: BackupCodec.decode(bytes))
    }
    public func validate() throws {
        guard format == "mihen.archive", archiveVersion == 2 else { throw PlanError.invalid("validation.version") }
        try BackupCodec.validate(document)
        if let prayer {
            guard prayer.latitude.isFinite, prayer.longitude.isFinite, abs(prayer.latitude) <= 90, abs(prayer.longitude) <= 180,
                  TimeZone(identifier: prayer.timeZoneID) != nil,
                  CalculationMethod(rawValue: prayer.method).map({ $0 != .other }) == true,
                  HighLatitudeRule(rawValue: prayer.highLatitude) != nil else { throw PlanError.invalid("validation.data") }
        }
    }
}
