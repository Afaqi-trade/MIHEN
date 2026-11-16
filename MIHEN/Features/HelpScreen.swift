import SwiftUI

struct HelpScreen: View {
    @Environment(AppStore.self) private var store
    private let topics = ["basics", "partial", "week", "backup", "permissions", "limits"]
    private var diagnostics: String {
        let version = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey:"CFBundleVersion") as? String ?? "?"
        return "MİHEN \(version) (\(build))\niOS \(UIDevice.current.systemVersion)\n" + store.t("help.diagnostics.safe")
    }
    var body: some View {
        List {
            Text(store.t("welcome.promise")).font(.headline)
            ForEach(topics,id: \.self) { topic in
                DisclosureGroup(store.t("help." + topic + ".title")) { Text(store.t("help." + topic + ".body")) }
            }
            Section(store.t("help.support")) {
                Text(store.t("help.support.body")).font(.footnote)
                ShareLink(item:diagnostics) { Text(store.t("help.diagnostics.share")) }
            }
            NavigationLink(destination:PolicyScreen()) { Text(store.t("privacy.policy")) }
        }.navigationTitle(store.t("help"))
    }
}
