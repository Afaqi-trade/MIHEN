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
        let enough=current.recordedDays.count >= 3 && previous.recordedDays.count >= 3
        let comparisons=Set(a.keys).union(b.keys).sorted { $0.id < $1.id }.map { key in
            MetricComparison(metric:key,current:a[key],previous:b[key],difference:enough ? a[key].flatMap { av in b[key].map { av-$0 } } : nil)
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
