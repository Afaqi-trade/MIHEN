import SwiftUI

struct NutritionScreen: View {
    @Environment(AppStore.self) private var store
    @State private var date = Date()
    @State private var kind = "food"
    @State private var amount = 0.0
    @State private var note = ""
    private var rows: [DomainActivityRecord] {
        store.data.activities.filter { ["food", "energyBurned", "water"].contains($0.kind) && store.engine.key($0.date) == store.engine.key(date) }
    }
    private func total(_ kind: String) -> Double { rows.filter { $0.kind == kind }.reduce(0) { $0 + $1.amount } }
    var body: some View {
        Form {
            NavigationLink(destination: HealthSummaryScreen()) { Text(store.t("health.connection")) }
            DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
            Section(store.t("nutrition.summary")) {
                Text(store.t("activity.food") + ": " + total("food").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.energyBurned") + ": " + total("energyBurned").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.water") + ": " + total("water").formatted(.number.locale(store.locale)) + " ml")
                Text(store.t("nutrition.explanation")).font(.footnote)
            }
            Section(store.t("activity.new")) {
                Picker(store.t("type"), selection: $kind) {
                    ForEach(["food", "energyBurned", "water"], id: \.self) { Text(store.t("activity." + $0)).tag($0) }
                }
                ValueInput(title: "amount", value: $amount)
                Text(kind == "water" ? "ml" : "kcal")
                TextField(store.t("notes"), text: $note)
                Button(store.t("save")) {
                    if store.change({ $0.activities.append(.init(domainID: "health", date: date, kind: kind, amount: amount, unit: kind == "water" ? "ml" : "kcal", note: note)) }) { amount = 0; note = "" }
                }.disabled(!amount.isFinite || amount <= 0)
            }
            Section(store.t("history")) {
                ForEach(rows.sorted { $0.date > $1.date }) { row in
                    VStack(alignment: .leading) {
                        Text(store.t("activity." + row.kind))
                        Text(row.amount.formatted(.number.locale(store.locale)) + " " + row.unit)
                        Text(row.note)
                    }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.activities.removeAll { $0.id == row.id } } } }
                }
            }
        }.keyboardDone().navigationTitle(store.t("nutrition"))
    }
}
