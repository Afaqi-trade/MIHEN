import Foundation

enum RecoveryBackup {
    static var url: URL {
        URL.applicationSupportDirectory.appendingPathComponent("MIHEN-Recovery.json")
    }
    static func preserve(_ document: BackupDocument) throws {
        let bytes = try BackupCodec.encode(document)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try bytes.write(to: url, options: [.atomic, .completeFileProtection])
    }
    static func load() throws -> BackupDocument {
        try BackupCodec.decode(Data(contentsOf: url))
    }
}
