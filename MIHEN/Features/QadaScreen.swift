import SwiftUI

struct QadaScreen: View {
    @Environment(AppStore.self) private var store
    @State private var prayer = "fajr"
    @State private var kind = "qadaDone"
    @State private var amount = 1
    @State private var date = Date()
    @State private var deleting: DomainActivityRecord?
    @State private var lastAdded: String?
    @State private var showWitr = true
    private let prayers = ["fajr", "dhuhr", "asr", "maghrib", "isha", "witr"]
    private func total(_ kind: String, _ prayer: String) -> Double {
        store.data.activities.filter { $0.kind == kind && $0.unit == prayer }.reduce(0) { $0 + $1.amount }
    }
    var body: some View {
        Form {
            Text(store.t("qada.explanation")).font(.footnote)
            if !store.data.activities.contains(where: { $0.kind == "qadaDebt" }) { Text(store.t("qada.first")).font(.footnote) }
            Toggle(store.t("qada.witr.optional"), isOn: $showWitr)
            if let lastAdded { Button(store.t("undo")) { if store.change({ $0.activities.removeAll { $0.id == lastAdded } }) { self.lastAdded = nil } } }
            ForEach(prayers.filter { $0 != "witr" || showWitr }, id: \.self) { prayer in
                HStack {
                    Text(store.t("prayer." + prayer))
                    Spacer()
                    Text(max(0, total("qadaDebt", prayer) - total("qadaDone", prayer)).formatted(.number.locale(store.locale))).accessibilityIdentifier("qada.remaining." + prayer)
                    Button { add(prayer: prayer, kind: "qadaDone", amount: 1) } label: { Image(systemName: "plus.circle").frame(minWidth: 44, minHeight: 44) }
                        .accessibilityLabel(store.t("qada.quick") + " · " + store.t("prayer." + prayer))
                        .disabled(total("qadaDebt", prayer) - total("qadaDone", prayer) < 1)
                }
            }
            Section(store.t("activity.new")) {
                Picker(store.t("qada.prayer"), selection: $prayer) { ForEach(prayers, id: \.self) { Text(store.t("prayer." + $0)).tag($0) } }
                Picker(store.t("qada.kind.label"), selection: $kind) { ForEach(["qadaDebt", "qadaDone"], id: \.self) { Text(store.t("activity." + $0)).tag($0) } }.accessibilityIdentifier("qada.kind")
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                IntegerInput(title: "amount", value: $amount)
                Button(store.t("save")) {
                    add(prayer: prayer, kind: kind, amount: amount)
                }.accessibilityIdentifier("qada.save").disabled(amount <= 0 || (kind == "qadaDone" && Double(amount) > total("qadaDebt", prayer) - total("qadaDone", prayer)))
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
        }.buttonStyle(.borderless).keyboardDone().navigationTitle(store.t("qada"))
            .confirmationDialog(store.t("delete.confirm"), isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
                Button(store.t("delete"), role: .destructive) {
                    guard let row = deleting else { return }
                    store.change { $0.activities.removeAll { $0.id == row.id } }
                    deleting = nil
                }
            }
    }
    private func add(prayer: String, kind: String, amount: Int) {
        let record = DomainActivityRecord(domainID: "spiritual", date: date, kind: kind, amount: Double(amount), unit: prayer)
        if store.change({ $0.activities.append(record) }) { lastAdded = record.id }
    }

}
