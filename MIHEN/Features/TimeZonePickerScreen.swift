import SwiftUI

struct TimeZonePickerScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: String
    @State private var search = ""
    private var zones: [String] { TimeZone.knownTimeZoneIdentifiers.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) || name($0).localizedCaseInsensitiveContains(search) } }
    private func name(_ id: String) -> String { TimeZone(identifier:id)?.localizedName(for:.generic,locale:store.locale) ?? id }
    var body: some View {
        List {
            if search.isEmpty {
                Section(store.t("timezone.common")) { ForEach(["Europe/Istanbul","Europe/London","Europe/Berlin","America/New_York","Asia/Riyadh","GMT"],id: \.self) { row($0) } }
            }
            Section(store.t("all")) { ForEach(zones,id: \.self) { row($0) } }
        }.navigationTitle(store.t("timezone")).searchable(text:$search,prompt:store.t("timezone.search"))
    }
    private func row(_ id: String) -> some View {
        Button { selection = id; dismiss() } label: {
            HStack { VStack(alignment:.leading) { Text(name(id)); Text(id).font(.caption).foregroundStyle(.secondary) }; Spacer(); if selection == id { Image(systemName:"checkmark") } }
        }.accessibilityAddTraits(selection == id ? .isSelected : [])
    }
}
