import SwiftUI

struct DomainActivityScreen: View {
    @Environment(AppStore.self) private var store
    let domainID: String
    @State private var amount = 1.0
    @State private var unit = "count"
    @State private var kind = "other"
    @State private var note = ""
    @State private var date = Date()
    var body: some View {
        List {
            Section(store.t("activity.new")) {
                Picker(store.t("type"), selection: $kind) {
                    ForEach(["exercise", "sleep", "income", "expense", "budget", "obligation", "giving", "volunteering", "learning", "other"], id: \.self) { Text(store.t("activity.\($0)")).tag($0) }
                }
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                ValueInput(title: "amount", value: $amount)
                UnitPicker(unit: $unit)
                TextField(store.t("notes"), text: $note, axis: .vertical)
                Button(store.t("save")) {
                    if store.change({ $0.activities.append(.init(domainID: domainID, date: date, kind: kind, amount: amount, unit: unit, note: note)) }) { note = "" }
                }.disabled(amount < 0)
            }
            Section(store.t("history")) {
                ForEach(store.data.activities.filter { $0.domainID == domainID }.sorted { $0.date > $1.date }) { row in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.t("activity.\(row.kind)")).font(.headline)
                        Text("\(row.amount.formatted(.number.locale(store.locale))) \(store.t(row.unit))")
                        Text(row.date, format: .dateTime.day().month().year()).font(.caption)
                        Text(row.note).foregroundStyle(.secondary)
                    }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.activities.removeAll { $0.id == row.id } } } }
                }
            }
        }.keyboardDone().navigationTitle(store.t("activity.log"))
    }
}
struct ProjectsScreen: View {
    @Environment(AppStore.self) private var store
    let domainID: String
    @State private var title = ""
    @State private var notes = ""
    @State private var goalID: String?
    var body: some View {
        List {
            Section(store.t("project.new")) {
                TextField(store.t("title"), text: $title).autocorrectionDisabled()
                TextField(store.t("notes"), text: $notes, axis: .vertical)
                Picker(store.t("linked.goal"), selection: $goalID) {
                    Text(store.t("none")).tag(String?.none)
                    ForEach(store.data.goals.filter { $0.domainIDs.contains(domainID) }) { Text($0.title).tag(Optional($0.id)) }
                }
                Button(store.t("save")) { if store.change({ $0.projects.append(.init(title: title, goalID: goalID, domainID: domainID, notes: notes)) }) { title = ""; notes = "" } }.disabled(title.isEmpty)
            }
            ForEach(store.data.projects.filter { $0.domainID == domainID }) { project in
                VStack(alignment: .leading) {
                    Text(project.title).font(.headline)
                    Text(project.notes)
                    Toggle(store.t("archived"), isOn: Binding(get: { project.archived }, set: { value in store.change { data in if let i = data.projects.firstIndex(where: { $0.id == project.id }) { data.projects[i].archived = value } } }))
                }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.projects.removeAll { $0.id == project.id } } } }
            }
        }.keyboardDone().navigationTitle(store.t("projects"))
    }
}
