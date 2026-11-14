import SwiftUI

@main struct MIHENApp: App {
    @State private var store: AppStore?
    @State private var startupError: String?
    var body: some Scene {
        WindowGroup {
            Group {
                if let store { RootView(store: store) }
                else if let startupError {
                    ContentUnavailableView("MİHEN", systemImage: "externaldrive.badge.exclamationmark", description: Text(startupError))
                } else { ProgressView().task { start() } }
            }
        }
    }
    @MainActor private func start() {
        do {
            var inMemory = false
            var storeURL: URL?
            #if DEBUG
            let args = ProcessInfo.processInfo.arguments
            inMemory = args.contains("--ui-testing")
            if let i = args.firstIndex(of: "--ui-test-store"), args.indices.contains(i + 1), let testID = UUID(uuidString: args[i + 1]) {
                let directory = URL.applicationSupportDirectory.appendingPathComponent("UITests/" + testID.uuidString)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                storeURL = directory.appendingPathComponent("testing.store")
                inMemory = false
            }
            #endif
            store = try AppStore(repository: Repository(inMemory: inMemory, storeURL: storeURL))
        } catch {
            // Never silently replace an unreadable store with an empty one.
            startupError = error.localizedDescription
        }
    }
}
