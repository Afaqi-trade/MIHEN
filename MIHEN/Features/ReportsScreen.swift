import SwiftUI

struct ReportsScreen: View {
    @Environment(AppStore.self) private var store
    @State private var period = "month"
    @State private var date = Date()
    private var interval: DateInterval {
        let calendar = store.engine.calendar
        if period == "report.tenYears" {
            let end = calendar.dateInterval(of: .year, for: date)!.end
            return DateInterval(start: calendar.date(byAdding: .year, value: -10, to: end)!, end: end)
        }
        return calendar.dateInterval(of: period == "year" ? .year : period == "week" ? .weekOfYear : .month, for: date)!
    }
    private var rows: [TaskOccurrenceRecord] {
        store.data.occurrences.filter { $0.day >= store.engine.key(interval.start) && $0.day < store.engine.key(interval.end) }
    }
    var body: some View {
        List {
            Picker(store.t("period"), selection: $period) {
                ForEach(["week", "month", "year", "report.tenYears"], id: \.self) { Text(store.t($0)).tag($0) }
            }
            DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
            Text(store.t("report.coverage")).font(.footnote)
            Text(interval.start, format: .dateTime.day().month().year())
            Text(store.engine.addingDays(-1, to: interval.end), format: .dateTime.day().month().year())
            ForEach(store.data.domains) { domain in
                Section(store.title(domain.id)) {
                    let records = rows.filter { $0.domainID == domain.id }
                    let planned = records.filter { !["skipped", "cancelled", "moved"].contains($0.status) }
                    let completed = planned.filter { $0.status == "completed" }.count
                    Text("\(completed) / \(planned.count) " + store.t("tasks.completed"))
                    Text(store.t("report.partial") + ": \(planned.filter { $0.status == "partial" }.count)")
                    if let first = records.map(\.day).min() { Text(store.t("report.first") + ": " + first) }
                    Text(store.t("report.goals.current")).font(.caption)
                    ForEach(store.data.goals.filter { $0.domainIDs.contains(domain.id) && $0.start < interval.end && $0.end >= interval.start }) { goal in
                        GoalLink(goal: goal)
                    }
                }
            }
        }.navigationTitle(store.t("reports"))
    }
}
