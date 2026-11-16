import SwiftUI

struct ReportsScreen: View {
    @Environment(AppStore.self) private var store
    @State private var period = "month"
    @State private var date = Date()
    @State private var exporting = false
    private var interval: DateInterval {
        let calendar = store.engine.calendar
        if period == "report.tenYears" {
            let end = calendar.dateInterval(of: .year, for: date)!.end
            return DateInterval(start: calendar.date(byAdding: .year, value: -10, to: end)!, end: end)
        }
        return calendar.dateInterval(of: period == "year" ? .year : period == "week" ? .weekOfYear : .month, for: date)!
    }
    private var report: PeriodReport { store.engine.periodReport(store.data, in: interval) }
    var body: some View {
        List {
            Section {
                Picker(store.t("period"), selection: $period) { ForEach(["week", "month", "year", "report.tenYears"], id: \.self) { Text(store.t($0)).tag($0) } }
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                Text(interval.start, format: .dateTime.day().month().year())
                Text(store.engine.addingDays(-1, to: interval.end), format: .dateTime.day().month().year())
                Text(store.t("report.recordedDays") + ": \(report.recordedDays.count)").accessibilityIdentifier("report.coverage.days")
                Text(store.t("report.coverage")).font(.footnote)
                Text(store.t("report.sources.explanation")).font(.footnote)
            }
            Section(store.t("report.steps")) {
                if report.planned == 0 { Text(store.t("report.noTasks")) }
                else { Text("\(report.completed) / \(report.planned) " + store.t("tasks.completed")) }
                Text(store.t("report.partial") + ": \(report.partial)")
                HStack { Text(store.t("skipped") + ": \(report.skipped)"); Text(store.t("cancelled") + ": \(report.cancelled)"); Text(store.t("moved") + ": \(report.moved)") }.font(.caption)
                DisclosureGroup(store.t("report.formula")) { Text(store.t("statistics.formula")).font(.footnote) }
            }
            ForEach(store.data.domains.sorted { $0.enabled == $1.enabled ? $0.rank < $1.rank : $0.enabled }) { domain in
                ReportDomainSection(domain: domain, interval: interval, report: report)
            }
            Section(store.t("report.next")) {
                NavigationLink(destination: WeeklyPlanScreen()) { Text(store.t("weekly.plan")) }
                NavigationLink(destination: JournalScreen()) { Text(store.t("report.reflect")) }
                Text(store.t("report.next.help")).font(.footnote)
            }
        }.navigationTitle(store.t("reports"))
            .toolbar { Button { exporting = true } label: { Image(systemName: "square.and.arrow.up") }.accessibilityLabel(store.t("report.export")) }
            .sheet(isPresented: $exporting) { ReportExportScreen(interval: interval) }
    }
}

private struct ReportDomainSection: View {
    @Environment(AppStore.self) private var store
    let domain: LifeDomainRecord
    let interval: DateInterval
    let report: PeriodReport
    private var goals: [GoalRecord] { store.data.goals.filter { $0.domainIDs.contains(domain.id) && $0.start < interval.end && $0.end >= interval.start } }
    private var notes: [JournalEntryRecord] { store.data.journals.filter { $0.domainID == domain.id && $0.date >= interval.start && $0.date < interval.end } }
    var body: some View {
        Section(store.title(domain.id)) {
            let metrics = report.metrics.filter { $0.domainID == domain.id }
            if metrics.isEmpty && goals.isEmpty && notes.isEmpty { Text(store.t("report.noData")).font(.subheadline).foregroundStyle(.secondary) }
            ForEach(metrics) { metric in
                LabeledContent(store.t(metric.key), value: metric.value.formatted(.number.locale(store.locale)) + " " + store.t(["fajr","dhuhr","asr","maghrib","isha","witr"].contains(metric.unit) ? "prayer." + metric.unit : metric.unit)).accessibilityIdentifier("report.metric." + metric.id)
            }
            ForEach(goals) { goal in
                VStack(alignment: .leading, spacing: 4) {
                    GoalLink(goal: goal)
                    let period = store.engine.contributions(goal.id, in: store.data, interval: interval)
                    Text(store.t("report.goal.period") + ": " + period.total.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)).font(.caption)
                    Text(store.t("contribution.tasks") + ": " + period.tasks.formatted(.number.locale(store.locale))).font(.caption)
                    Text(store.t("contribution.manual") + ": " + period.manual.formatted(.number.locale(store.locale))).font(.caption)
                    Text(store.t("report.goals.current")).font(.caption).foregroundStyle(.secondary)
                }
            }
            ForEach(notes) { row in Text(row.text).font(.subheadline) }
        }
    }
}
