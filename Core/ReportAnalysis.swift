import Foundation

public struct ReportMetricKey: Hashable, Sendable, Identifiable {
    public let domainID: String
    public let key: String
    public let unit: String
    public var id: String { "\(domainID.count):\(domainID)\(key.count):\(key)\(unit.count):\(unit)" }
    public init(_ metric: ReportMetric) { domainID=metric.domainID;key=metric.key;unit=metric.unit }
}
public struct MetricComparison: Identifiable, Sendable {
    public let metric: ReportMetricKey
    public let current: Double?
    public let previous: Double?
    public let difference: Double?
    public let currentDays: Int
    public let previousDays: Int
    public var id: String { metric.id }
}
public struct ReportBucket: Identifiable, Sendable {
    public let interval: DateInterval
    public let report: PeriodReport
    public var id: Date { interval.start }
}
public struct ReportAnalysis: Sendable {
    public let current: PeriodReport
    public let previous: PeriodReport
    public let previousInterval: DateInterval
    public let comparisons: [MetricComparison]
    public let buckets: [ReportBucket]
    public let firstRecordedDay: String?
    public let lastRecordedDay: String?
}
extension PlanningEngine {
    public func previousEqualInterval(_ interval: DateInterval) -> DateInterval {
        let count=max(1,calendar.dateComponents([.day],from:calendar.startOfDay(for:interval.start),to:calendar.startOfDay(for:interval.end)).day ?? 1)
        return .init(start:addingDays(-count,to:interval.start),end:interval.start)
    }
    public func analyzeReport(_ data: BackupDocument, interval: DateInterval, component: Calendar.Component) -> ReportAnalysis {
        let current=periodReport(data,in:interval),previousInterval=previousEqualInterval(interval)
        let previous=periodReport(data,in:previousInterval)
        let a=Dictionary(uniqueKeysWithValues:current.metrics.map { (ReportMetricKey($0),$0.value) })
        let b=Dictionary(uniqueKeysWithValues:previous.metrics.map { (ReportMetricKey($0),$0.value) })
        let comparisons=Set(a.keys).union(b.keys).sorted { $0.id < $1.id }.map { key in
            let currentDays=metricDays(key,in:data,interval:interval),previousDays=metricDays(key,in:data,interval:previousInterval)
            return MetricComparison(metric:key,current:a[key],previous:b[key],difference:currentDays >= 3 && previousDays >= 3 ? a[key].flatMap { av in b[key].map { av-$0 } } : nil,currentDays:currentDays,previousDays:previousDays)
        }
        var cursor=interval.start,buckets=[ReportBucket]()
        while cursor < interval.end && buckets.count < 120 {
            guard let period=calendar.dateInterval(of:component,for:cursor) else { break }
            let end=min(period.end,interval.end)
            guard end > cursor else { break }
            let bucket=DateInterval(start:cursor,end:end)
            buckets.append(.init(interval:bucket,report:periodReport(data,in:bucket)));cursor=end
        }
        let days=current.recordedDays.sorted()
        return .init(current:current,previous:previous,previousInterval:previousInterval,comparisons:comparisons,buckets:buckets,firstRecordedDay:days.first,lastRecordedDay:days.last)
    }
    private func metricDays(_ metric: ReportMetricKey,in data: BackupDocument,interval: DateInterval) -> Int {
        var dates=[Date]()
        switch metric.key {
        case "report.reading": dates=data.readings.map(\.date)
        case "report.reviews": dates=data.memorizationReviews.map(\.date)
        case "report.fasts": dates=data.fasts.filter { $0.status == "completed" }.map(\.date)
        case "dhikr": dates=data.dhikr.filter { $0.value > 0 }.compactMap { date($0.day) }
        default:
            dates=data.effectiveActivities(engine:self).filter {
                $0.domainID == metric.domainID && $0.unit == metric.unit && ("activity."+$0.kind == metric.key || (metric.key.hasPrefix("report.qada.") && ["qadaDebt","qadaDone"].contains($0.kind)))
            }.map(\.date)
        }
        return Set(dates.filter { $0 >= interval.start && $0 < interval.end }.map { key($0) }).count
    }
    public func reportInterval(period: String, containing date: Date, now: Date) -> DateInterval {
        let selected=min(date,now)
        let raw: DateInterval
        if period == "report.tenYears" {
            let end=calendar.dateInterval(of:.year,for:selected)!.end
            raw = .init(start:calendar.date(byAdding:.year,value:-10,to:end)!,end:end)
        } else { raw=calendar.dateInterval(of:period == "week" ? .weekOfYear : period == "year" ? .year : .month,for:selected)! }
        return .init(start:raw.start,end:min(raw.end,addingDays(1,to:calendar.startOfDay(for:now))))
    }
}
extension BackupDocument {
    /// Projection for reports only: not a valid backup and never used to replace the store.
    public func scopedReport(areas: Set<String>, includeNotes: Bool) -> BackupDocument {
        var result=self
        result.occurrences.removeAll { !areas.contains($0.domainID) }
        result.activities.removeAll { !areas.contains($0.domainID) }
        let goals=Set(goals.filter { $0.domainIDs.contains(where:areas.contains) }.map(\.id))
        result.goalProgress.removeAll { !goals.contains($0.goalID) }
        if !areas.contains("learning") { result.readings=[];result.memorizationReviews=[] }
        if !areas.contains("spiritual") { result.dhikr=[];result.fasts=[] }
        result.journals=includeNotes ? result.journals.filter { $0.domainID.map(areas.contains) ?? false } : []
        let journals=Set(result.journals.map(\.id))
        result.reviewResponses.removeAll { !journals.contains($0.journalID) }
        return result
    }
}

public struct ReportAreaSummary: Identifiable, Sendable {
    public let id: String
    public let report: PeriodReport
    public let activeGoals: Int
    public let goalsNeedingReview: Int
}
public struct ExecutiveReport: Sendable {
    public let analysis: ReportAnalysis
    public let areas: [ReportAreaSummary]
    public let elapsedDays: Int
    public let overloadedDays: Int
    public let unknownDuration: Int
    public let goalsNeedingReview: Int
}
extension PlanningEngine {
    public func executiveReport(_ data: BackupDocument, interval: DateInterval, period: String, now: Date) -> ExecutiveReport {
        let component:Calendar.Component = period == "report.tenYears" ? .year : period == "year" ? .month : period == "month" ? .weekOfYear : .day
        let analysis=analyzeReport(data,interval:interval,component:component)
        let areas=data.domains.sorted { $0.rank < $1.rank }.map { domain in
            let scoped=data.scopedReport(areas:[domain.id],includeNotes:true)
            let goals=data.goals.filter { !$0.archived && $0.domainIDs.contains(domain.id) && $0.start < interval.end && $0.end >= interval.start }
            let overdue=goals.filter { $0.end < calendar.startOfDay(for:now) && contributions($0.id,in:data).total < $0.target }.count
            return ReportAreaSummary(id:domain.id,report:periodReport(scoped,in:interval),activeGoals:goals.count,goalsNeedingReview:overdue)
        }
        let week=calendar.dateInterval(of:.weekOfYear,for:now)!
        let loads=days(from:week.start,through:addingDays(-1,to:week.end)).map { workload(data,on:$0) }
        return .init(analysis:analysis,areas:areas,elapsedDays:calendar.dateComponents([.day],from:interval.start,to:interval.end).day ?? 0,overloadedDays:loads.filter { $0.excess > 0 }.count,unknownDuration:loads.reduce(0) { $0+$1.unknown },goalsNeedingReview:data.goals.filter { !$0.archived && $0.start < interval.end && $0.end >= interval.start && $0.end < calendar.startOfDay(for:now) && contributions($0.id,in:data).total < $0.target }.count)
    }
}
