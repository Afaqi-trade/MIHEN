import SwiftUI

@main struct MIHENApp: App {
    @State private var store: AppStore?
    @State private var startupError: String?
    var body: some Scene {
        WindowGroup {
            Group {
                if let store { RootView(store: store) }
                else if let startupError {
                    VStack(spacing: 16) {
                        ContentUnavailableView("MİHEN", systemImage: "externaldrive.badge.exclamationmark", description: Text(Localization.text("startup.safe",language:Locale.current.languageCode == "tr" ? "tr" : "en")))
                        Button(Localization.text("startup.retry",language:Locale.current.languageCode == "tr" ? "tr" : "en")) { self.startupError = nil; start() }.buttonStyle(.borderedProminent)
                        DisclosureGroup(Localization.text("startup.details",language:Locale.current.languageCode == "tr" ? "tr" : "en")) { Text(startupError).font(.caption).textSelection(.enabled) }.padding()
                    }
                } else { ProgressView().task { start() } }
            }
            #if DEBUG
            .modifier(UITestTextSize())
            #endif
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
            let loaded = try AppStore(repository: Repository(inMemory: inMemory, storeURL: storeURL))
            store = loaded
            PrivacyCurtain.shared.attach(loaded)
        } catch {
            // Never silently replace an unreadable store with an empty one.
            startupError = error.localizedDescription
        }
    }
}

#if DEBUG
/// Exercise the real SwiftUI hierarchy at deterministic content sizes in UI tests.
/// No override is present in Release, or without the explicit test launch flag.
private struct UITestTextSize: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--ui-testing") && arguments.contains("--ui-text-xs") {
            content.environment(\.dynamicTypeSize, .xSmall)
        } else if arguments.contains("--ui-testing") && arguments.contains("--ui-text-ax5") {
            content.environment(\.dynamicTypeSize, .accessibility5)
        } else { content }
    }
}
#endif
