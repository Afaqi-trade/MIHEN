import Foundation

public struct ReportMetric: Identifiable, Equatable, Sendable {
    public let id: String
    public let domainID: String
    public let key: String
    public let unit: String
    public let value: Double
}
public struct PeriodReport: Sendable {
    public var planned = 0
    public var completed = 0
    public var partial = 0
    public var skipped = 0
    public var cancelled = 0
    public var moved = 0
    public var recordedDays = Set<String>()
    public var taskRecordedDays = Set<String>()
    public var metrics: [ReportMetric] = []
}
extension PlanningEngine {
    public func periodReport(_ data: BackupDocument, in interval: DateInterval) -> PeriodReport {
        var report = PeriodReport()
        let lower = key(interval.start), upper = key(interval.end)
        func includes(_ date: Date) -> Bool { date >= interval.start && date < interval.end }
        func includeDay(_ date: Date) -> Bool { let k = key(date); return k >= lower && k < upper }
        let rows = data.occurrences.filter { $0.day >= lower && $0.day < upper }
        report.planned = rows.filter { !["skipped","cancelled","moved"].contains($0.status) }.count
        report.completed = rows.filter { $0.status == "completed" }.count
        report.partial = rows.filter { $0.status == "partial" }.count
        report.skipped = rows.filter { $0.status == "skipped" }.count
        report.cancelled = rows.filter { $0.status == "cancelled" }.count
        report.moved = rows.filter { $0.status == "moved" }.count
        for row in rows where row.value > 0 && row.status != "moved" { report.recordedDays.insert(row.day);report.taskRecordedDays.insert(row.day) }
        func metric(_ id: String, _ domain: String, _ key: String, _ unit: String, _ value: Double) {
            report.metrics.append(.init(id:id,domainID:domain,key:key,unit:unit,value:value))
        }
        let readings = data.readings.filter { includes($0.date) }
        if !readings.isEmpty {
            metric("readings","learning","report.reading","pages",Double(readings.reduce(0) { $0 + $1.pages }))
            readings.forEach { report.recordedDays.insert(key($0.date)) }
        }
        let reviews = data.memorizationReviews.filter { includes($0.date) }
        if !reviews.isEmpty { metric("reviews","learning","report.reviews","count",Double(reviews.count)); reviews.forEach { report.recordedDays.insert(key($0.date)) } }
        let dhikr = data.dhikr.filter { $0.day >= lower && $0.day < upper && $0.value > 0 }
        if !dhikr.isEmpty { metric("dhikr","spiritual","dhikr","count",Double(dhikr.reduce(0) { $0 + $1.value })); dhikr.forEach { report.recordedDays.insert($0.day) } }
        let fasts = data.fasts.filter { includeDay($0.date) && $0.status == "completed" }
        if !fasts.isEmpty { metric("fasts","spiritual","report.fasts","days",Double(fasts.count)); fasts.forEach { report.recordedDays.insert(key($0.date)) } }
        let activities = data.effectiveActivities(engine: self).filter { includes($0.date) }
        activities.forEach { report.recordedDays.insert(key($0.date)) }
        // Each source retains its own unit. Never merge module quantities with task contributions.
        struct ActivityKey: Hashable { let domain: String; let kind: String; let unit: String }
        let grouped = Dictionary(grouping:activities.filter { !["qadaDebt","qadaDone"].contains($0.kind) }) { ActivityKey(domain:$0.domainID,kind:$0.kind,unit:$0.unit) }
        for (_, items) in grouped.sorted(by: { ($0.key.domain,$0.key.kind,$0.key.unit) < ($1.key.domain,$1.key.kind,$1.key.unit) }) {
            if let first = items.first { metric("activity." + first.id,first.domainID,"activity."+first.kind,first.unit,items.reduce(0) { $0 + $1.amount }) }
        }
        for prayer in ["fajr","dhuhr","asr","maghrib","isha","witr"] {
            let ledger = data.activities.filter { $0.unit == prayer && ["qadaDebt","qadaDone"].contains($0.kind) }
            guard ledger.contains(where: { $0.date < interval.end }) else { continue }
            let opening = ledger.filter { $0.date < interval.start }.reduce(0.0) { $0 + ($1.kind == "qadaDebt" ? $1.amount : -$1.amount) }
            let added = ledger.filter { includes($0.date) && $0.kind == "qadaDebt" }.reduce(0) { $0 + $1.amount }
            let done = ledger.filter { includes($0.date) && $0.kind == "qadaDone" }.reduce(0) { $0 + $1.amount }
            metric(prayer+"opening","spiritual","report.qada.opening",prayer,opening)
            metric(prayer+"added","spiritual","report.qada.added",prayer,added)
            metric(prayer+"done","spiritual","report.qada.done",prayer,done)
            metric(prayer+"closing","spiritual","report.qada.closing",prayer,opening+added-done)
        }
        data.goalProgress.filter { includes($0.date) }.forEach { report.recordedDays.insert(key($0.date)) }
        data.journals.filter { includes($0.date) }.forEach { report.recordedDays.insert(key($0.date)) }
        return report
    }
}
