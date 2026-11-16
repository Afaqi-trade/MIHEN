import SwiftUI
import Charts

struct ProgressScreen: View {
    @Environment(AppStore.self) private var store
    @State private var period = "week"
    private var interval: DateInterval {
        let component: Calendar.Component = period == "year" ? .year : period == "month" ? .month : period == "day" ? .day : .weekOfYear
        return store.engine.calendar.dateInterval(of: component, for: Date())!
    }
    private var series: [DaySummary] {
        store.engine.days(from: interval.start, through: Date()).map { store.engine.summary(store.data, on: $0) }
    }
    private var chartSeries: [DaySummary] {
        guard period == "year" else { return series }
        let groups = Dictionary(grouping: series) { String($0.day.prefix(7)) + "-01" }
        return groups.keys.sorted().map { key in
            let values = groups[key] ?? []
            let planned = values.reduce(0) { $0 + $1.planned }, completed = values.reduce(0) { $0 + $1.completed }
            return DaySummary(day: key, planned: planned, completed: completed, partial: values.reduce(0) { $0 + $1.partial }, ratio: planned > 0 ? Double(completed) / Double(planned) : nil)
        }
    }
    private var totals: (Int, Int) { (series.reduce(0) { $0 + $1.completed }, series.reduce(0) { $0 + $1.planned }) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: ReportsScreen()) { Label(store.t("reports"), systemImage: "doc.text") }
                Picker(store.t("period"), selection: $period) { ForEach(["day", "week", "month", "year"], id: \.self) { Text(store.t($0)).tag($0) } }.pickerStyle(.segmented)
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.t("completion.rate")).font(.headline)
                    Text(totals.1 > 0 ? (Double(totals.0) / Double(totals.1)).formatted(.percent.precision(.fractionLength(0)).locale(store.locale)) : "—").font(.largeTitle.bold())
                    Text("\(totals.0) / \(totals.1) " + store.t("tasks.completed"))
                    Text(store.t("statistics.formula")).font(.caption).foregroundStyle(.secondary)
                    Text(comparison).font(.subheadline)
                }.mihenCard()
                Chart(chartSeries, id: \.day) { day in
                    if let date = store.engine.date(day.day), let ratio = day.ratio {
                        BarMark(x: .value(store.t("date"), date, unit: .day), y: .value(store.t("progress"), ratio * 100)).foregroundStyle(Color.mihenGreen)
                    }
                }
                .chartXScale(domain: interval.start...interval.end)
                .chartXAxis {
                    AxisMarks(values: .stride(by: period == "year" ? .month : .day, count: period == "month" ? 7 : 1)) { _ in
                        AxisGridLine()
                        if period == "year" { AxisValueLabel(format: .dateTime.month(.abbreviated)) }
                        else { AxisValueLabel(format: .dateTime.day()) }
                    }
                }
                .chartYScale(domain: 0...100).frame(height: 200).accessibilityLabel(store.t("chart.progress")).accessibilityValue("\(totals.0) / \(totals.1) " + store.t("tasks.completed"))
                Text(store.t("eight.areas")).font(.title2.bold())
                ForEach(store.data.domains.filter(\.enabled)) { area in
                    let days = store.engine.days(from: interval.start, through: Date()).map { store.engine.summary(store.data, on: $0, domainID: area.id) }
                    let total = days.reduce(0) { $0 + $1.planned }, done = days.reduce(0) { $0 + $1.completed }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.title(area.id)).font(.headline)
                        if total > 0 { ProgressView(value: Double(done) / Double(total)); Text("\(done) / \(total)").font(.caption) }
                        else { Text(store.t("qualitative.only")).font(.caption).foregroundStyle(.secondary) }
                    }.mihenCard()
                }
                Text(store.t("heatmap")).font(.title2.bold())
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(store.engine.days(from: store.engine.addingDays(-27, to: Date()), through: Date()), id: \.self) { date in
                        let summary = store.engine.summary(store.data, on: date)
                        Text(date, format: .dateTime.day()).font(.caption).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(Color.mihenGreen.opacity(summary.ratio == nil ? 0.04 : 0.1 + (summary.ratio ?? 0) * 0.35), in: RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel(store.engine.key(date) + ": \(summary.completed)/\(summary.planned)")
                    }
                }
                NavigationLink(destination: JournalScreen()) { Text(store.t("reviews")) }
            }.padding()
        }.background(Color.mihenBackground).navigationTitle(store.t("progress"))
    }
    private var comparison: String {
        let elapsed = store.engine.days(from: interval.start, through: Date()).count
        let previousStart = store.engine.addingDays(-elapsed, to: interval.start)
        let previousEnd = store.engine.addingDays(-1, to: interval.start)
        let previous = store.engine.days(from: previousStart, through: previousEnd).map { store.engine.summary(store.data, on: $0) }
        let denominator = previous.reduce(0) { $0 + $1.planned }, numerator = previous.reduce(0) { $0 + $1.completed }
        guard denominator > 0 else { return store.t("comparison.noData") }
        return store.t("comparison.previous") + ": " + (Double(numerator) / Double(denominator)).formatted(.percent.precision(.fractionLength(0)).locale(store.locale))
    }
}
struct JournalScreen: View {
    @Environment(AppStore.self) private var store
    var domainID: String? = nil
    @State private var add = false
    @State private var kind = "note"
    @State private var edit: JournalEntryRecord?
    var body: some View {
        List {
            Picker(store.t("type"), selection: $kind) { ForEach(["note", "weekly", "monthly"], id: \.self) { Text(store.t($0)).tag($0) } }
            ForEach(store.data.journals.filter { $0.kind == kind && (domainID == nil || $0.domainID == domainID) }.sorted { $0.date > $1.date }) { row in
                Button { edit = row } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(row.date, format: .dateTime.day().month().year()).font(.caption).foregroundStyle(.secondary)
                        Text(row.text).foregroundStyle(.primary)
                    }
                }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.journals.removeAll { $0.id == row.id } } } }
            }
        }.keyboardDone().navigationTitle(store.t("notes.reviews"))
            .toolbar { Button { add = true } label: { Image(systemName: "plus") } }
            .sheet(isPresented: $add) { JournalEditor(kind: kind, domainID: domainID) }
            .sheet(item: $edit) { JournalEditor(entry: $0) }
    }
}
struct JournalEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var well = ""
    @State private var adjust = ""
    @State private var next = ""
    @State private var draft: JournalEntryRecord
    init(entry: JournalEntryRecord? = nil, kind: String = "note", domainID: String? = nil) { _draft = State(initialValue: entry ?? .init(domainID: domainID, kind: kind)) }
    var body: some View {
        NavigationStack {
            Form {
                if draft.kind != "note" {
                    Section(store.t("review.summary")) {
                        let component: Calendar.Component = draft.kind == "weekly" ? .weekOfYear : .month
                        let interval = store.engine.calendar.dateInterval(of: component, for: draft.date)!
                        let rows = store.data.occurrences.filter { (draft.domainID == nil || $0.domainID == draft.domainID) && $0.day >= store.engine.key(interval.start) && $0.day < store.engine.key(interval.end) && !["skipped", "cancelled", "moved"].contains($0.status) }
                        Text("\(rows.filter { $0.status == "completed" }.count) / \(rows.count) " + store.t("tasks.completed"))
                        TextField(store.t("review.well"), text: $well, axis: .vertical)
                        TextField(store.t("review.adjust"), text: $adjust, axis: .vertical)
                        TextField(store.t("review.next"), text: $next, axis: .vertical)
                    }
                }
                DatePicker(store.t("date"), selection: $draft.date, displayedComponents: .date)
                Picker(store.t("area"), selection: $draft.domainID) {
                    Text(store.t("all")).tag(String?.none)
                    ForEach(store.data.domains) { Text(store.title($0.id)).tag(Optional($0.id)) }
                }
                TextEditor(text: $draft.text).frame(minHeight: 250).accessibilityLabel(store.t("notes"))
            }.keyboardDone().navigationTitle(store.t(draft.kind))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        var record = draft
                        let answers = [("review.well", well), ("review.adjust", adjust), ("review.next", next)].filter { !$0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.map { store.t($0.0) + "\n" + $0.1 }
                        record.text = ([draft.text] + answers).filter { !$0.isEmpty }.joined(separator: "\n\n")
                        if store.change({ data in if let i = data.journals.firstIndex(where: { $0.id == record.id }) { data.journals[i] = record } else { data.journals.append(record) } }) { dismiss() }
                    }.disabled([draft.text, well, adjust, next].allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) }
                }
        }
    }
}
