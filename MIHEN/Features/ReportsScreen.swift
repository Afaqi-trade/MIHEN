import SwiftUI
import Charts

struct ReportsScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var period="month"
    @State private var date=Date()
    @State private var exporting=false
    @State private var executive: ExecutiveReport?
    private var interval: DateInterval { store.engine.reportInterval(period:period,containing:date,now:Date()) }
    private var requestID: String { "\(store.revision):\(period):\(store.engine.key(date))" }
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:20) {
                controls
                if let executive {
                    ReportExecutiveHero(data:executive,interval:interval)
                    ReportHighlights(data:executive)
                    ReportTrendCard(analysis:executive.analysis,period:period)
                    areaOverview(executive)
                    ReportNextActions(data:executive)
                    DisclosureGroup(store.t("report.formula")) {
                        VStack(alignment:.leading,spacing:12) {
                            Text(store.t("report.coverage"));Text(store.t("report.sources.explanation"))
                            Text(store.t("statistics.formula"));Text(store.t("report.cutoff.help"))
                        }.font(.footnote)
                    }.mihenCard()
                } else { ProgressView().frame(maxWidth:.infinity,minHeight:180).accessibilityLabel(store.t("report.loading")) }
            }.padding()
        }.background(Color.mihenBackground).navigationTitle(store.t("reports")).navigationBarTitleDisplayMode(.inline)
            .toolbar { Button { exporting=true } label: { Image(systemName:"square.and.arrow.up") }.accessibilityLabel(store.t("report.export")).accessibilityIdentifier("report.export.open") }
            .sheet(isPresented:$exporting) { ReportExportScreen(interval:interval) }
            .task(id:requestID) {
                executive=nil
                let snapshot=store.data,engine=store.engine,range=interval,selected=period,now=Date()
                let result=await Task.detached(priority:.userInitiated) { engine.executiveReport(snapshot,interval:range,period:selected,now:now) }.value
                if !Task.isCancelled { executive=result }
            }
    }
    private var controls: some View {
        VStack(alignment:.leading,spacing:12) {
            Picker(store.t("period"),selection:$period) { ForEach(["week","month","year","report.tenYears"],id:\.self) { Text(store.t($0)).tag($0) } }.pickerStyle(.menu).accessibilityIdentifier("report.period")
            DatePicker(store.t("report.anchorDate"),selection:$date,in:...Date(),displayedComponents:.date)
        }.mihenCard()
    }
    private func areaOverview(_ data: ExecutiveReport) -> some View {
        VStack(alignment:.leading,spacing:14) {
            Text(store.t("report.areas.overview")).font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text(store.t("report.areas.help")).font(.subheadline).foregroundStyle(.secondary)
            ForEach(data.areas) { area in
                NavigationLink(destination:ReportAreaDetail(area:area,interval:interval)) {
                    ReportAreaCard(area:area)
                }.buttonStyle(.plain).accessibilityIdentifier("report.area."+area.id)
            }
            NavigationLink(destination:ReportAnalysisScreen(interval:interval,period:period)) { Label(store.t("report.analysis"),systemImage:"chart.xyaxis.line") }.accessibilityIdentifier("report.analysis").frame(minHeight:44)
        }
    }
}

private struct ReportExecutiveHero: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dynamicTypeSize) private var size
    let data: ExecutiveReport
    let interval: DateInterval
    private var report: PeriodReport { data.analysis.current }
    private var columns: [GridItem] { Array(repeating:GridItem(.flexible(),alignment:.leading),count:size.isAccessibilitySize ? 1 : 2) }
    var body: some View {
        VStack(alignment:.leading,spacing:20) {
            HStack { Label(store.t("report.executive"),systemImage:"sparkle").font(.subheadline.weight(.semibold));Spacer();MihenMotif().stroke(.white.opacity(0.45),lineWidth:1).frame(width:36,height:36).accessibilityHidden(true) }
            Text(report.recordedDays.isEmpty ? store.t("report.executive.empty") : store.t("report.executive.title")).font(.system(.largeTitle,design:.serif).weight(.semibold)).fixedSize(horizontal:false,vertical:true)
            Text(dateRange).font(.subheadline)
            Text(store.t("report.executive.help")).font(.subheadline).fixedSize(horizontal:false,vertical:true)
            Divider().overlay(.white.opacity(0.3))
            LazyVGrid(columns:columns,alignment:.leading,spacing:20) {
                stat(String(report.completed),"today.finished")
                stat(String(report.partial),"report.partial")
                stat("\(report.recordedDays.count) / \(data.elapsedDays)","report.recordedDays")
                stat(String(data.areas.filter { !$0.report.recordedDays.isEmpty }.count)+" / 8","report.areas.recorded")
            }
            if report.planned > 0 {
                ProgressView(value:Double(report.completed),total:Double(report.planned)).tint(Color.white)
                    .accessibilityLabel(store.t("report.steps")).accessibilityValue("\(report.completed) / \(report.planned)")
                Text("\(report.completed) / \(report.planned) "+store.t("tasks.completed")).font(.caption)
            }
            Text(store.t("report.recordedDays")+": \(report.recordedDays.count)").font(.caption).accessibilityIdentifier("report.coverage.days")
        }.padding(24).frame(maxWidth:.infinity,alignment:.leading)
            .foregroundStyle(.white)
            .background(LinearGradient(colors:[Color.mihenNavy,Color(red:0.08,green:0.29,blue:0.30)],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:28))
            .accessibilityIdentifier("report.executive.hero")
    }
    private var dateRange: String {
        let style=Date.FormatStyle(date:.abbreviated,time:.omitted,locale:store.locale,calendar:store.engine.calendar,timeZone:store.engine.timeZone)
        return interval.start.formatted(style)+" – "+store.engine.addingDays(-1,to:interval.end).formatted(style)
    }
    private func stat(_ value: String,_ key: String) -> some View {
        VStack(alignment:.leading,spacing:4) { Text(value).font(.title.bold().monospacedDigit());Text(store.t(key)).font(.subheadline) }.accessibilityElement(children:.combine)
    }
}

private struct ReportHighlights: View {
    @Environment(AppStore.self) private var store
    let data: ExecutiveReport
    private var current: PeriodReport { data.analysis.current }
    private var previous: PeriodReport { data.analysis.previous }
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text(store.t("report.highlights")).font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Label(store.t("report.compare"),systemImage:"arrow.left.arrow.right").font(.headline)
            if current.taskRecordedDays.count >= 3 && previous.taskRecordedDays.count >= 3 && current.planned > 0 && previous.planned > 0 {
                let difference=current.completed-previous.completed
                Text((difference > 0 ? "+" : "")+String(difference)+" "+store.t("report.steps.change")).font(.title3.bold()).foregroundStyle(Color.mihenGreen)
                Text(store.t("report.current")+": \(current.completed) / \(current.planned) · "+store.t("comparison.previous")+": \(previous.completed) / \(previous.planned)")
            } else { Text(store.t("report.compare.insufficient")) }
            Text(store.t("report.compare.help")).font(.caption).foregroundStyle(.secondary)
            Divider()
            Label(store.t("report.attention"),systemImage:"magnifyingglass").font(.headline)
            Text(store.t("report.partial")+": \(current.partial) · "+store.t("report.skipped")+": \(current.skipped)")
            Text(store.t("report.goals.review")+": \(data.goalsNeedingReview)")
            Text(store.t("report.attention.help")).font(.caption).foregroundStyle(.secondary)
        }.mihenCard()
    }
}

struct ReportTrendCard: View {
    @Environment(AppStore.self) private var store
    let analysis: ReportAnalysis
    let period: String
    @State private var metric="steps"
    private var selected: MetricComparison? { analysis.comparisons.first { $0.id == metric } }
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text(store.t("report.trend")).font(.title2.bold()).accessibilityAddTraits(.isHeader).accessibilityIdentifier("report.trend.title")
            Picker(store.t("report.metric"),selection:$metric) {
                Text(store.t("report.steps")).tag("steps")
                ForEach(analysis.comparisons) { item in Text(label(item)).tag(item.id) }
            }.pickerStyle(.menu)
            if analysis.current.recordedDays.isEmpty { Text(store.t("report.noData")) }
            else {
                Chart {
                    ForEach(analysis.buckets) { bucket in
                        if let value=value(bucket) {
                            BarMark(x:.value(store.t("date"),bucket.interval.start),y:.value(store.t("amount"),value)).foregroundStyle(Color.mihenGreen.gradient).cornerRadius(4)
                        }
                    }
                }.chartXScale(domain:analysis.buckets.first!.interval.start...analysis.buckets.last!.interval.end)
                    .chartXAxis { AxisMarks(values:.automatic(desiredCount:4)) { _ in AxisGridLine();AxisValueLabel(format:period == "report.tenYears" ? .dateTime.year() : period == "year" ? .dateTime.month(.abbreviated) : .dateTime.day().month(.abbreviated)) } }
                    .frame(height:200).accessibilityLabel(store.t("report.trend")).accessibilityValue(selected.map(label) ?? store.t("report.steps"))
            }
            Text(store.t("report.trend.help")).font(.caption).foregroundStyle(.secondary)
            DisclosureGroup(store.t("report.trend.table")) {
                ForEach(analysis.buckets) { bucket in
                    VStack(alignment:.leading) {
                        Text(bucket.interval.start,format:.dateTime.day().month().year()).font(.caption)
                        Text(value(bucket).map { $0.formatted(.number.locale(store.locale))+" "+unit } ?? store.t("report.noData"))
                    }.frame(maxWidth:.infinity,alignment:.leading).padding(.vertical,5)
                }
            }
        }.mihenCard()
    }
    private var unit: String { selected.map { store.reportUnit($0.metric.unit) } ?? store.t("report.completedSteps") }
    private func value(_ bucket: ReportBucket) -> Double? {
        guard let selected else { return bucket.report.planned > 0 ? Double(bucket.report.completed) : nil }
        return bucket.report.metrics.first { ReportMetricKey($0) == selected.metric }?.value
    }
    private func label(_ item: MetricComparison) -> String { store.title(item.metric.domainID)+" · "+store.t(item.metric.key)+" · "+store.reportUnit(item.metric.unit) }
}

private struct ReportAreaCard: View {
    @Environment(AppStore.self) private var store
    let area: ReportAreaSummary
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            HStack(alignment:.top) {
                Image(systemName:LifeArea(rawValue:area.id)?.symbol ?? "leaf").font(.title2).foregroundStyle(Color.mihenGreen).frame(width:32)
                Text(store.title(area.id)).font(.headline)
                Spacer(minLength:4);Image(systemName:"chevron.right").font(.caption).accessibilityHidden(true)
            }
            Text(store.t("report.recordedDays")+": \(area.report.recordedDays.count) · "+store.t("goals")+": \(area.activeGoals)").font(.caption).foregroundStyle(.secondary)
            if area.report.planned > 0 {
                ProgressView(value:Double(area.report.completed),total:Double(area.report.planned)).tint(.mihenGreen)
                Text("\(area.report.completed) / \(area.report.planned) "+store.t("tasks.completed")+" · \(area.report.partial) "+store.t("today.started")).font(.subheadline)
            }
            if let item=area.report.metrics.first { Text(store.t(item.key)+": "+item.value.formatted(.number.locale(store.locale))+" "+store.reportUnit(item.unit)).font(.subheadline) }
            else if area.report.recordedDays.isEmpty { Text(store.t("report.noData")).font(.subheadline) }
        }.mihenCard().contentShape(Rectangle())
    }
}
private struct ReportAreaDetail: View {
    @Environment(AppStore.self) private var store
    let area: ReportAreaSummary
    let interval: DateInterval
    var body: some View {
        List {
            Text(store.t("report.sources.explanation")).font(.footnote)
            if let domain=store.data.domains.first(where:{ $0.id == area.id }) { ReportDomainSection(domain:domain,interval:interval,report:area.report) }
            NavigationLink(destination:DomainScreen(domainID:area.id)) { Text(store.t("report.openArea")) }
        }.navigationTitle(store.title(area.id)).navigationBarTitleDisplayMode(.inline)
    }
}
private struct ReportNextActions: View {
    @Environment(AppStore.self) private var store
    let data: ExecutiveReport
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            Text(store.t("report.next")).font(.title2.bold()).accessibilityAddTraits(.isHeader)
            if data.capacityConfigured { Text(store.t("report.thisWeek.capacity")+": \(data.overloadedDays)").font(.headline) }
            else { NavigationLink(destination:CapacityScreen()) { Text(store.t("report.capacity.setup")) } }
            Text(store.t("report.duration.unknown")+": \(data.unknownDuration)").font(.subheadline)
            NavigationLink(destination:WeeklyPlanScreen()) { Label(store.t("week.focus.select"),systemImage:"calendar") }.frame(minHeight:44)
            NavigationLink(destination:ReportDecisionScreen()) { Label(store.t("report.decide"),systemImage:"slider.horizontal.3") }.frame(minHeight:44)
            NavigationLink(destination:JournalScreen()) { Label(store.t("report.reflect"),systemImage:"square.and.pencil") }.frame(minHeight:44)
            Text(store.t("report.next.help")).font(.caption).foregroundStyle(.secondary)
        }.mihenCard()
    }
}

struct ReportDomainSection: View {
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
                let isPrayer = ["fajr","dhuhr","asr","maghrib","isha","witr"].contains(metric.unit)
                let unit = store.t(isPrayer ? "prayer." + metric.unit : metric.unit)
                let number = metric.value.formatted(.number.locale(store.locale))
                let label = isPrayer ? unit + " · " + store.t(metric.key) : store.t(metric.key)
                LabeledContent(label, value: number + (isPrayer ? "" : " " + unit))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(label).accessibilityValue(number + " " + unit)
                    .accessibilityIdentifier("report.metric." + metric.id)
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
            ForEach(notes) { row in
                Text(row.text).font(.subheadline)
                if let response=store.data.reviewResponses.first(where: { $0.journalID == row.id }) {
                    ForEach([(store.t("review.well"),response.well),(store.t("review.adjust"),response.adjust),(store.t("review.next"),response.next)],id:\.0) { label,value in if !value.isEmpty { Text(label+": "+value).font(.subheadline) } }
                }
            }
        }
    }
}
