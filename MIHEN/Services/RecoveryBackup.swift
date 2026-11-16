import Foundation

enum RecoveryBackup {
    static var url: URL {
        URL.applicationSupportDirectory.appendingPathComponent("MIHEN-Recovery.json")
    }
    static func preserve(_ document: BackupDocument, prayer: PrayerSettings? = nil, at destination: URL = url) throws {
        let bytes = try BackupArchive(document: document, prayer: prayer).encoded()
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try bytes.write(to: destination, options: [.atomic, .completeFileProtection])
    }
    static func load(from source: URL = url) throws -> BackupDocument {
        try loadArchive(from: source).document
    }
    static func loadArchive(from source: URL = url) throws -> BackupArchive {
        try BackupArchive.decode(Data(contentsOf: source))
    }
}
