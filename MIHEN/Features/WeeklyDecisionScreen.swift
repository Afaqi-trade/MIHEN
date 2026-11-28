import SwiftUI

struct WeeklyDecisionScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let rows: [TaskOccurrenceRecord]
    @State private var selected = Set<String>()
    @State private var action = "move"
    @State private var destination = Date()
    @State private var confirmation = false
    private func proposed(_ data: BackupDocument) throws -> BackupDocument {
        var result = data
        for row in rows where selected.contains(row.id) {
            guard let i = result.occurrences.firstIndex(where: { $0.id == row.id }), ["planned","partial"].contains(result.occurrences[i].status) else { throw PlanError.invalid("validation.closed") }
            if action == "move" { try store.engine.move(row.id, to: destination, in: &result) }
            else { result.occurrences[i].status = "skipped" }
        }
        try BackupCodec.validate(result); return result
    }
    private var error: String? {
        do { _ = try proposed(store.data); return nil } catch { return (error as? PlanError)?.errorDescription ?? "validation.data" }
    }
    var body: some View {
        NavigationStack {
            Form {
                Text(store.t("week.decide.help")).font(.footnote)
                ForEach(rows) { row in
                    Toggle(store.taskTitle(row.title) + " · " + row.day, isOn: Binding(get: { selected.contains(row.id) }, set: { if $0 { selected.insert(row.id) } else { selected.remove(row.id) } })).accessibilityIdentifier("weekly.review.row." + row.id)
                }
                Picker(store.t("type"), selection:$action) { Text(store.t("move")).tag("move"); Text(store.t("skipped")).tag("skip") }
                if action == "move" { DatePicker(store.t("date"),selection:$destination,in:store.engine.calendar.startOfDay(for:Date())...,displayedComponents:.date) }
                if !selected.isEmpty {
                    Text(store.t("week.review.selected") + ": \(selected.count)").accessibilityIdentifier("weekly.review.selected")
                    let partial = rows.filter { selected.contains($0.id) && $0.value > 0 }.count
                    if partial > 0 { Text(store.t("week.review.partial") + ": \(partial)").font(.footnote) }
                }
                if let error { Text(store.t(error)).font(.footnote) }
                Button(store.t("week.decide.apply")) { confirmation = true }.disabled(selected.isEmpty || error != nil)
            }.navigationTitle(store.t("week.decide"))
                .toolbar { Button(store.t("cancel")) { dismiss() } }
                .confirmationDialog(store.t("week.decide.confirm"),isPresented:$confirmation) {
                    Button(store.t("week.decide.apply")) { if store.change({ $0 = try proposed($0) }) { dismiss() } }
                }
        }
    }
}
