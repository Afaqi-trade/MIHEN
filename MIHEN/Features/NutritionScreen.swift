import SwiftUI

struct NutritionScreen: View {
    @Environment(AppStore.self) private var store
    @State private var date = Date()
    @State private var kind = "food"
    @State private var amount = 0.0
    @State private var note = ""
    @State private var lastAdded: String?
    private var rows: [DomainActivityRecord] {
        store.data.activities.filter { ["food", "energyBurned", "water"].contains($0.kind) && store.engine.key($0.date) == store.engine.key(date) }
    }
    private func total(_ kind: String) -> Double { store.data.effectiveActivities(engine: store.engine).filter { $0.kind == kind && store.engine.key($0.date) == store.engine.key(date) }.reduce(0) { $0 + $1.amount } }
    private var usesHealth: Bool { rows.contains { $0.id.hasPrefix("health.energy:") } }
    var body: some View {
        Form {
            NavigationLink(destination: HealthSummaryScreen()) { Text(store.t("health.connection")) }
            DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
            Section(store.t("nutrition.summary")) {
                Text(store.t("activity.food") + ": " + total("food").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.energyBurned") + ": " + total("energyBurned").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.water") + ": " + total("water").formatted(.number.locale(store.locale)) + " ml")
                Text(store.t(usesHealth ? "health.source" : "manual.source")).font(.caption)
                DisclosureGroup(store.t("report.formula")) { Text(store.t("nutrition.explanation")).font(.footnote) }
            }
            Section(store.t("nutrition.quick")) {
                HStack {
                    Button("+250 ml") { addWater(250) }; Button("+500 ml") { addWater(500) }
                }.buttonStyle(.borderless)
                if let lastAdded { Button(store.t("undo")) { if store.change({ $0.activities.removeAll { $0.id == lastAdded } }) { self.lastAdded = nil } } }
            }
            Section(store.t("activity.new")) {
                Picker(store.t("type"), selection: $kind) {
                    ForEach(["food", "energyBurned", "water"], id: \.self) { Text(store.t("activity." + $0)).tag($0) }
                }
                ValueInput(title: "amount", value: $amount)
                Text(store.t(kind == "water" ? "nutrition.amount.water" : "nutrition.amount.energy")).font(.caption)
                if kind == "energyBurned" && usesHealth { Text(store.t("health.source.help")).font(.footnote) }
                TextField(store.t("notes"), text: $note)
                Button(store.t("save")) {
                    if store.change({ $0.activities.append(.init(domainID: "health", date: date, kind: kind, amount: amount, unit: kind == "water" ? "ml" : "kcal", note: note)) }) { amount = 0; note = "" }
                }.disabled(!amount.isFinite || amount <= 0 || (kind == "energyBurned" && usesHealth))
            }
            Section(store.t("history")) {
                ForEach(rows.sorted { $0.date > $1.date }) { row in
                    VStack(alignment: .leading) {
                        Text(store.t("activity." + row.kind))
                        Text(store.t(row.id.hasPrefix("health.") ? "health.source" : "manual.source")).font(.caption)
                        Text(row.amount.formatted(.number.locale(store.locale)) + " " + row.unit)
                        Text(row.note)
                    }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.activities.removeAll { $0.id == row.id } } } }
                }
            }
        }.keyboardDone().navigationTitle(store.t("nutrition"))
    }
    private func addWater(_ value: Double) {
        let record = DomainActivityRecord(domainID: "health", date: date, kind: "water", amount: value, unit: "ml")
        if store.change({ $0.activities.append(record) }) { lastAdded = record.id }
    }
}
