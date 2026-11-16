import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ReportExportScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let interval: DateInterval
    @State private var selected = Set<String>()
    @State private var includeNotes = false
    @State private var includeComparison = false
    @State private var exporting = false
    @State private var document: TransferDocument?
    @State private var type = UTType.pdf
    private var filtered: BackupDocument {
        store.data.scopedReport(areas:selected,includeNotes:includeNotes)
    }
    private var rows: [[String]] {
        let data = filtered, report = store.engine.periodReport(data, in: interval)
        var rows = [[store.t("period"), store.engine.key(interval.start), store.engine.key(store.engine.addingDays(-1, to: interval.end))], [store.t("report.recordedDays"), String(report.recordedDays.count)], [store.t("completed"), String(report.completed)], [store.t("report.partial"), String(report.partial)], [store.t("skipped"), String(report.skipped)], [store.t("cancelled"), String(report.cancelled)], [store.t("moved"), String(report.moved)]]
        for item in report.metrics { rows.append([store.title(item.domainID),store.t(item.key),item.value.formatted(.number.grouping(.never).locale(store.locale)),store.t(["fajr","dhuhr","asr","maghrib","isha","witr"].contains(item.unit) ? "prayer." + item.unit : item.unit)]) }
        for goal in data.goals where goal.domainIDs.contains(where: { selected.contains($0) }) {
            let contribution = store.engine.contributions(goal.id, in: data, interval: interval)
            rows.append([goal.title, store.t("report.goal.period"), contribution.total.formatted(.number.grouping(.never).locale(store.locale)),store.t(goal.unit)])
        }
        for note in data.journals where note.date >= interval.start && note.date < interval.end {
            rows.append([store.t("notes"),store.engine.key(note.date),note.text])
            if let response=data.reviewResponses.first(where: { $0.journalID == note.id }) {
                rows.append([store.t("review.well"),response.well]);rows.append([store.t("review.adjust"),response.adjust]);rows.append([store.t("review.next"),response.next])
            }
        }
        if includeComparison {
            let days=store.engine.calendar.dateComponents([.day],from:interval.start,to:interval.end).day ?? 1
            let component:Calendar.Component = days > 366 ? .year : days > 31 ? .month : .weekOfYear
            let analysis=store.engine.analyzeReport(data,interval:interval,component:component)
            rows.append([store.t("report.compare"),store.engine.key(analysis.previousInterval.start),store.engine.key(store.engine.addingDays(-1,to:analysis.previousInterval.end))])
            for item in analysis.comparisons {
                let current=item.current.map { $0.formatted(.number.grouping(.never).locale(store.locale)) } ?? store.t("report.noData")
                let previous=item.previous.map { $0.formatted(.number.grouping(.never).locale(store.locale)) } ?? store.t("report.noData")
                rows.append([store.title(item.metric.domainID),store.t(item.metric.key),store.t("report.current"),current,store.t("comparison.previous"),previous,store.t(item.metric.unit)])
            }
            for bucket in analysis.buckets {
                rows.append([store.engine.key(bucket.interval.start),store.t("report.recordedDays"),String(bucket.report.recordedDays.count)])
                for item in bucket.report.metrics { rows.append([store.title(item.domainID),store.t(item.key),item.value.formatted(.number.grouping(.never).locale(store.locale)),store.t(item.unit)]) }
            }
        }
        return rows
    }
    var body: some View {
        NavigationStack {
            Form {
                Text(store.t("report.export.help")).font(.footnote)
                ForEach(store.data.domains) { domain in
                    Toggle(store.title(domain.id), isOn: Binding(get: { selected.contains(domain.id) }, set: { if $0 { selected.insert(domain.id) } else { selected.remove(domain.id) } }))
                }
                Toggle(store.t("report.export.notes"), isOn: $includeNotes)
                Toggle(store.t("report.export.comparison"),isOn:$includeComparison)
                Picker(store.t("report.export.format"), selection: $type) { Text("PDF").tag(UTType.pdf); Text("CSV").tag(UTType.commaSeparatedText) }
                Button(store.t("report.export")) {
                    let data = type == .pdf ? renderPDF(rows: rows) : Data(CSV.encode(rows.map { $0.map(CSV.safeCell) }).utf8)
                    document = .init(data: data); exporting = true
                }.disabled(selected.isEmpty).buttonStyle(.borderedProminent).accessibilityIdentifier("report.export.confirm")
            }.navigationTitle(store.t("report.share.title"))
                .toolbar { Button(store.t("close")) { dismiss() } }
                .fileExporter(isPresented: $exporting, document: document, contentType: type, defaultFilename: "MIHEN-Report-" + store.engine.key(interval.start)) { result in
                    if case .failure(let error) = result { store.errorMessage = error.localizedDescription }
                }
        }
    }
    private func renderPDF(rows: [[String]]) -> Data {
        PeriodReportPDF.render(title: "MİHEN · " + store.t("reports"), paragraphs: [store.t("report.coverage"),store.t("report.sources.explanation")] + rows.map { $0.joined(separator:" · ") })
    }
}
