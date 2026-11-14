import SwiftUI

struct CustomRemindersScreen: View {
    @Environment(AppStore.self) private var store
    @State private var kind = "water"
    @State private var time = Date()
    var body: some View {
        Form {
            Text(store.t("custom.reminders.explanation")).font(.footnote)
            Picker(store.t("type"), selection: $kind) {
                ForEach(["water", "movement", "review"], id: \.self) { Text(store.t("reminder." + $0)).tag($0) }
            }
            DatePicker(store.t("date"), selection: $time, displayedComponents: .hourAndMinute)
            Button(store.t("add")) {
                let parts = store.engine.calendar.dateComponents([.hour, .minute], from: time)
                store.change { $0.notificationPreferences.append(.init(kind: kind, enabled: true, hour: parts.hour ?? 9, minute: parts.minute ?? 0)) }
            }
            ForEach(store.data.notificationPreferences.filter { ["water", "movement", "review"].contains($0.kind) }) { row in
                Toggle(isOn: Binding(get: { row.enabled }, set: { value in store.change { data in if let i = data.notificationPreferences.firstIndex(where: { $0.id == row.id }) { data.notificationPreferences[i].enabled = value } } })) {
                    Text(store.t("reminder." + row.kind) + " · " + String(format: "%02d:%02d", row.hour, row.minute))
                }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.notificationPreferences.removeAll { $0.id == row.id } } } }
            }
        }.navigationTitle(store.t("custom.reminders"))
    }
}
