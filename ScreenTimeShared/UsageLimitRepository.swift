import Foundation
import FamilyControls
import Darwin

struct UsageLimitDocument: Codable {
    var version = 1
    var policy = UsageLimitPolicy()
    var selection = FamilyActivitySelection()
}
struct UsageLimitRepository {
    let folder: URL
    init(folder: URL) { self.folder = folder }
    static func shared() throws -> Self {
        guard let group = Bundle.main.object(forInfoDictionaryKey: "MihenAppGroup") as? String,
              let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else { throw PlanError.invalid("screen.group.required") }
        return .init(folder: folder.appendingPathComponent("UsageLimits", isDirectory: true))
    }
    func read() throws -> UsageLimitDocument { try access(write: false, { _ in }) }
    @discardableResult func update(_ body: (inout UsageLimitDocument) throws -> Void, afterCommit: (UsageLimitDocument) -> Void = { _ in }) throws -> UsageLimitDocument {
        try access(write: true, body, afterCommit: afterCommit)
    }
    func reset(afterCommit: (UsageLimitDocument) -> Void) throws {
        _ = try access(write: true, replace: true, { $0 = UsageLimitDocument() }, afterCommit: afterCommit)
    }
    private func access(write: Bool, replace: Bool = false, _ body: (inout UsageLimitDocument) throws -> Void, afterCommit: (UsageLimitDocument) -> Void = { _ in }) throws -> UsageLimitDocument {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        let descriptor = open(folder.appendingPathComponent("state.lock").path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw PlanError.invalid("screen.storage.error") }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else { throw PlanError.invalid("screen.storage.error") }
        defer { flock(descriptor, LOCK_UN) }
        let url = folder.appendingPathComponent("state.json")
        var document = UsageLimitDocument()
        if !replace && FileManager.default.fileExists(atPath: url.path) {
            document = try JSONDecoder().decode(UsageLimitDocument.self, from: Data(contentsOf: url))
            guard document.version == 1, (1...720).contains(document.policy.minutes) else { throw PlanError.invalid("screen.storage.error") }
        }
        try body(&document)
        guard (1...720).contains(document.policy.minutes) else { throw PlanError.invalid("screen.invalid") }
        if write {
            try JSONEncoder().encode(document).write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
            // Serialize the shield effect with the state commit across the app and extension.
            afterCommit(document)
        }
        return document
    }
}
