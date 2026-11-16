import SwiftUI

struct StarterTemplatesScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selected = Set<String>()
    var body: some View {
        List {
            Text(store.t("starter.explanation")).font(.footnote)
            ForEach(StarterTemplate.choices) { item in
                Toggle(isOn: Binding(get: { selected.contains(item.id) }, set: { if $0 { selected.insert(item.id) } else { selected.remove(item.id) } })) {
                    VStack(alignment: .leading) {
                        Text(store.t(item.id))
                        Text(item.target.formatted(.number.locale(store.locale)) + " " + store.t(item.unit) + " · " + store.t("daily")).font(.caption).foregroundStyle(.secondary)
                    }
                }.disabled(store.data.tasks.contains(where: { $0.id == "starter:\(item.id)" }))
            }
            Text("\(selected.count) " + store.t("starter.selected"))
            NavigationLink(destination:TemplateWeekPreview(selected:selected)) { Text(store.t("template.preview")) }.accessibilityIdentifier("template.preview")
            Button(store.t("starter.apply")) {
                let engine = store.engine
                if store.change({ $0.addSelectedTemplates(selected, on: Date(), engine: engine) }) { dismiss() }
            }.disabled(selected.isEmpty).buttonStyle(.borderedProminent)
        }.navigationTitle(store.t("templates.choose"))
    }
}
