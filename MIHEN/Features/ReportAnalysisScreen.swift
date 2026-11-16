import SwiftUI
import Charts

struct ReportAnalysisScreen: View {
    @Environment(AppStore.self) private var store
    let interval: DateInterval
    let period: String
    @State private var analysis: ReportAnalysis?
    @State private var selected=""
    private var component: Calendar.Component { period == "report.tenYears" ? .year : period == "year" ? .month : .weekOfYear }
    var body: some View {
        List {
            if let analysis {
                coverage(analysis)
                comparison(analysis)
                timeline(analysis)
                Section(store.t("report.next")) {
                    NavigationLink(destination:WeeklyPlanScreen()) { Text(store.t("week.focus.select")) }
                    NavigationLink(destination:JournalEditor(kind:period == "report.tenYears" ? "decadal" : period == "year" ? "yearly" : period == "week" ? "weekly" : "monthly")) { Text(store.t("report.reflect")) }
                    NavigationLink(destination:ReportDecisionScreen()) { Text(store.t("report.decide")) }.accessibilityIdentifier("report.decide")
                }
            } else { ProgressView() }
        }.navigationTitle(store.t("report.analysis"))
            .task(id:store.revision) {
                let snapshot=store.data,engine=store.engine,range=interval,bucket=component
                let result=await Task.detached(priority:.userInitiated) { engine.analyzeReport(snapshot,interval:range,component:bucket) }.value
                if !Task.isCancelled { analysis=result;if selected.isEmpty { selected=result.comparisons.first?.id ?? "" } }
            }
    }
    private func coverage(_ data: ReportAnalysis) -> some View {
        Section(store.t("report.coverage.title")) {
            Text(store.t("report.recordedDays")+": \(data.current.recordedDays.count)")
            Text(store.t("report.firstRecord")+": "+(data.firstRecordedDay ?? store.t("report.noData")))
            Text(store.t("report.lastRecord")+": "+(data.lastRecordedDay ?? store.t("report.noData")))
            Text(store.t("report.cutoff.help")).font(.footnote)
        }
    }
    private func comparison(_ data: ReportAnalysis) -> some View {
        Section(store.t("report.compare")) {
            Text(data.previousInterval.start,format:.dateTime.day().month().year())
            Text(store.engine.addingDays(-1,to:data.previousInterval.end),format:.dateTime.day().month().year())
            Text(store.t("report.recordedDays")+": \(data.previous.recordedDays.count)")
            Text(store.t("report.compare.help")).font(.footnote)
            if data.comparisons.isEmpty { Text(store.t("report.noData")) }
            ForEach(data.comparisons) { item in
                VStack(alignment:.leading,spacing:6) {
                    Text(store.title(item.metric.domainID)+" · "+store.t(item.metric.key)).font(.headline)
                    Text(store.t("report.current")+": "+value(item.current,unit:item.metric.unit))
                    Text(store.t("comparison.previous")+": "+value(item.previous,unit:item.metric.unit))
                    if let difference=item.difference { Text(store.t("report.difference")+": "+value(difference,unit:item.metric.unit)) }
                }
            }
        }
    }
    private func timeline(_ data: ReportAnalysis) -> some View {
        Section(store.t("report.trend")) {
            if !data.comparisons.isEmpty {
                Picker(store.t("report.metric"),selection:$selected) {
                    ForEach(data.comparisons) { item in Text(store.title(item.metric.domainID)+" · "+store.t(item.metric.key)+" ("+store.t(item.metric.unit)+")").tag(item.id) }
                }
                if let chosen=data.comparisons.first(where: { $0.id == selected }) {
                    Chart {
                        ForEach(data.buckets) { bucket in
                            if let metric=bucket.report.metrics.first(where: { ReportMetricKey($0) == chosen.metric }) {
                                BarMark(x:.value("Date",bucket.interval.start),y:.value(chosen.metric.unit,metric.value)).foregroundStyle(Color.mihenGreen)
                            }
                        }
                    }.frame(height:200).accessibilityLabel(store.t("report.trend")+" · "+store.t(chosen.metric.unit))
                    Text(store.t("report.trend.help")).font(.footnote)
                }
            }
            ForEach(data.buckets) { bucket in
                DisclosureGroup {
                    ForEach(bucket.report.metrics) { item in Text(store.t(item.key)+": "+value(item.value,unit:item.unit)) }
                } label: {
                    VStack(alignment:.leading) {
                        Text(bucket.interval.start,format:.dateTime.day().month().year())
                        Text(store.t("report.recordedDays")+": \(bucket.report.recordedDays.count)")
                        if bucket.report.recordedDays.isEmpty { Text(store.t("report.noData")) }
                    }
                }
            }
        }
    }
    private func value(_ number: Double?,unit: String) -> String {
        guard let number else { return store.t("report.noData") }
        let unitKey=["fajr","dhuhr","asr","maghrib","isha","witr"].contains(unit) ? "prayer."+unit : unit
        return number.formatted(.number.locale(store.locale))+" "+store.t(unitKey)
    }
}
struct ReportDecisionScreen: View {
    @Environment(AppStore.self) private var store
    @State private var target: GoalRecord?
    @State private var confirm: GoalRecord?
    var body: some View {
        List {
            Text(store.t("report.decide.help"))
            NavigationLink(destination:WeeklyPlanScreen()) { Text(store.t("week.decide")) }
            ForEach(store.data.goals.filter { !$0.archived }) { goal in
                Section(goal.title) {
                    Button(store.t("report.lighten")) { target=goal }
                    Button(store.t("planning.archive")) { confirm=goal }
                }
            }
        }.buttonStyle(.borderless).navigationTitle(store.t("report.decide"))
            .sheet(item:$target) { GoalEditor(goal:$0) }
            .confirmationDialog(store.t("planning.archive.confirm"),isPresented:Binding(get:{ confirm != nil },set:{ if !$0 { confirm=nil } })) {
                Button(store.t("planning.archive")) {
                    guard let goal=confirm else { return };let engine=store.engine
                    store.change { engine.archiveFutureGoalPlan(goal.id,on:Date(),in:&$0) };confirm=nil
                }
            }
    }
}
