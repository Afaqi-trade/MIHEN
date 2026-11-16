import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ReportExportScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let interval: DateInterval
    @State private var selected = Set<String>()
    @State private var includeNotes = false
    @State private var exporting = false
    @State private var document: TransferDocument?
    @State private var type = UTType.pdf
    private var filtered: BackupDocument {
        var result = store.data
        result.occurrences.removeAll { !selected.contains($0.domainID) }
        result.activities.removeAll { !selected.contains($0.domainID) }
        let goalIDs = Set(result.goals.filter { !$0.domainIDs.allSatisfy { !selected.contains($0) } }.map(\.id))
        result.goalProgress.removeAll { !goalIDs.contains($0.goalID) }
        if !selected.contains("learning") { result.readings = []; result.memorizationReviews = [] }
        if !selected.contains("spiritual") { result.dhikr = []; result.fasts = [] }
        result.journals = includeNotes ? result.journals.filter { $0.domainID.map { selected.contains($0) } ?? false } : []
        return result
    }
    private var rows: [[String]] {
        let data = filtered, report = store.engine.periodReport(data, in: interval)
        var rows = [[store.t("period"), store.engine.key(interval.start), store.engine.key(store.engine.addingDays(-1, to: interval.end))], [store.t("report.recordedDays"), String(report.recordedDays.count)], [store.t("completed"), String(report.completed)], [store.t("report.partial"), String(report.partial)], [store.t("skipped"), String(report.skipped)], [store.t("cancelled"), String(report.cancelled)], [store.t("moved"), String(report.moved)]]
        for item in report.metrics { rows.append([store.title(item.domainID),store.t(item.key),item.value.formatted(.number.grouping(.never).locale(store.locale)),store.t(["fajr","dhuhr","asr","maghrib","isha","witr"].contains(item.unit) ? "prayer." + item.unit : item.unit)]) }
        for goal in data.goals where goal.domainIDs.contains(where: { selected.contains($0) }) {
            let contribution = store.engine.contributions(goal.id, in: data, interval: interval)
            rows.append([goal.title, store.t("report.goal.period"), contribution.total.formatted(.number.grouping(.never).locale(store.locale)),store.t(goal.unit)])
        }
        for note in data.journals where note.date >= interval.start && note.date < interval.end { rows.append([store.t("notes"), store.engine.key(note.date),note.text]) }
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
                Picker(store.t("report.export.format"), selection: $type) { Text("PDF").tag(UTType.pdf); Text("CSV").tag(UTType.commaSeparatedText) }
                Button(store.t("report.export")) {
                    let data = type == .pdf ? renderPDF(rows: rows) : Data(CSV.encode(rows.map { $0.map(CSV.safeCell) }).utf8)
                    document = .init(data: data); exporting = true
                }.disabled(selected.isEmpty).buttonStyle(.borderedProminent)
            }.navigationTitle(store.t("report.export"))
                .toolbar { Button(store.t("close")) { dismiss() } }
                .fileExporter(isPresented: $exporting, document: document, contentType: type, defaultFilename: "MIHEN-Report-" + store.engine.key(interval.start)) { result in
                    if case .failure(let error) = result { store.errorMessage = error.localizedDescription }
                }
        }
    }
    private func renderPDF(rows: [[String]]) -> Data {
        let bounds = CGRect(x:0,y:0,width:595,height:842)
        let renderer = UIGraphicsPDFRenderer(bounds:bounds)
        return renderer.pdfData { context in
            var y: CGFloat = 50
            func newPage() {
                context.beginPage(); y = 50
                ("MİHEN · " + store.t("reports") as NSString).draw(at: CGPoint(x:44,y:y), withAttributes:[.font:UIFont.boldSystemFont(ofSize:20),.foregroundColor:UIColor.black]); y += 36
            }
            newPage()
            for line in [store.t("report.coverage"),store.t("report.sources.explanation")] + rows.map({ $0.joined(separator:" · ") }) {
                let attributes: [NSAttributedString.Key:Any] = [.font:UIFont.systemFont(ofSize:11),.foregroundColor:UIColor.black]
                // Long notes are divided into bounded lines to avoid crossing page boundaries.
                for piece in line.components(separatedBy:"\n") {
                    var remaining = piece[...]
                    while !remaining.isEmpty {
                        let chunk = String(remaining.prefix(100)); remaining = remaining.dropFirst(min(100,remaining.count))
                        let height = (chunk as NSString).boundingRect(with:CGSize(width:507,height:1000),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:attributes,context:nil).height + 8
                        if y + height > 790 { newPage() }
                        (chunk as NSString).draw(in:CGRect(x:44,y:y,width:507,height:height),withAttributes:attributes); y += height
                    }
                }
            }
        }
    }
}
