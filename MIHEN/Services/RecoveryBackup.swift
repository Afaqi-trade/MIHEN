import Foundation

enum RecoveryBackup {
    static var url: URL {
        URL.applicationSupportDirectory.appendingPathComponent("MIHEN-Recovery.json")
    }
    static func preserve(_ document: BackupDocument, at destination: URL = url) throws {
        let bytes = try BackupCodec.encode(document)
        try FileManager.default.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try bytes.write(to: destination, options: [.atomic, .completeFileProtection])
    }
    static func load(from source: URL = url) throws -> BackupDocument {
        try BackupCodec.decode(Data(contentsOf: source))
    }
}
