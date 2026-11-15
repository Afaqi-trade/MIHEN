import SwiftUI

struct QadaScreen: View {
    @Environment(AppStore.self) private var store
    @State private var prayer = "fajr"
    @State private var kind = "qadaDone"
    @State private var amount = 1
    @State private var date = Date()
    @State private var deleting: DomainActivityRecord?
    private let prayers = ["fajr", "dhuhr", "asr", "maghrib", "isha", "witr"]
    private func total(_ kind: String, _ prayer: String) -> Double {
        store.data.activities.filter { $0.kind == kind && $0.unit == prayer }.reduce(0) { $0 + $1.amount }
    }
    var body: some View {
        Form {
            Text(store.t("qada.explanation")).font(.footnote)
            ForEach(prayers, id: \.self) { prayer in
                HStack {
                    Text(store.t("prayer." + prayer))
                    Spacer()
                    Text(max(0, total("qadaDebt", prayer) - total("qadaDone", prayer)).formatted(.number.locale(store.locale)))
                }
            }
            Section(store.t("activity.new")) {
                Picker(store.t("type"), selection: $prayer) { ForEach(prayers, id: \.self) { Text(store.t("prayer." + $0)).tag($0) } }
                Picker(store.t("type"), selection: $kind) { ForEach(["qadaDebt", "qadaDone"], id: \.self) { Text(store.t("activity." + $0)).tag($0) } }
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                IntegerInput(title: "amount", value: $amount)
                Button(store.t("save")) {
                    store.change { $0.activities.append(.init(domainID: "spiritual", date: date, kind: kind, amount: Double(amount), unit: prayer)) }
                }.disabled(amount <= 0 || (kind == "qadaDone" && Double(amount) > total("qadaDebt", prayer) - total("qadaDone", prayer)))
            }
            Section(store.t("history")) {
                ForEach(store.data.activities.filter { ["qadaDebt", "qadaDone"].contains($0.kind) }.sorted { $0.date > $1.date }) { row in
                    VStack(alignment: .leading) {
                        Text(store.t("prayer." + row.unit) + " · " + store.t("activity." + row.kind))
                        Text(row.amount.formatted(.number.locale(store.locale)))
                        Text(row.date, format: .dateTime.day().month().year())
                        Button(store.t("delete"), role: .destructive) { deleting = row }
                    }
                }
            }
        }.keyboardDone().navigationTitle(store.t("qada"))
            .confirmationDialog(store.t("delete.confirm"), isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
                Button(store.t("delete"), role: .destructive) {
                    guard let row = deleting else { return }
                    store.change { $0.activities.removeAll { $0.id == row.id } }
                    deleting = nil
                }
            }
    }
}
