import Foundation

/// Editable Excel interchange, deliberately separate from the lossless backup CSV.
public enum PlanCSV {
    public static let header = ["type", "id", "title", "domain", "target", "unit", "start", "end", "recurrence"]
    public struct Preview: Sendable {
        public var goals: [GoalRecord] = []
        public var tasks: [PlannedTaskRecord] = []
        public var errors: [String] = []
        public var canImport: Bool { errors.isEmpty && (!goals.isEmpty || !tasks.isEmpty) }
    }
    public static func preview(_ text: String, into current: BackupDocument, engine: PlanningEngine) throws -> Preview {
        let rows = try CSV.parse(text)
        guard rows.first == header else { throw PlanError.invalid("validation.csvHeader") }
        var result = Preview(), ids = Set(current.goals.map(\.id) + current.tasks.map(\.id))
        for (index, row) in rows.dropFirst().enumerated() {
            do {
                guard row.count == header.count else { throw PlanError.invalid("validation.csv") }
                let id = row[1].isEmpty ? UUID().uuidString : row[1]
                guard ids.insert(id).inserted else { throw PlanError.invalid("validation.duplicates") }
                let area = LifeArea.allCases.first { $0.rawValue == row[3] || $0.titleTR == row[3] || $0.titleEN == row[3] }
                guard let area, let domain = current.domains.first(where: { $0.key == area.rawValue }), let target = Double(row[4]), target.isFinite, target > 0, let start = engine.date(row[6]), let end = engine.date(row[7]), end >= start, !row[2].isEmpty else { throw PlanError.invalid("validation.data") }
                let title = row[2].hasPrefix("'") ? String(row[2].dropFirst()) : row[2]
                if row[0] == "goal" {
                    result.goals.append(.init(id: id, title: title, domainIDs: [domain.id], start: start, end: end, target: target, unit: row[5]))
                } else if row[0] == "task", Recurrence(rawValue: row[8]) != nil {
                    result.tasks.append(.init(id: id, title: title, domainID: domain.id, start: start, end: end, recurrence: row[8], target: target, unit: row[5]))
                } else { throw PlanError.invalid("validation.csvEntity") }
            } catch { result.errors.append("\(index + 2): \(error.localizedDescription)") }
        }
        return result
    }
    public static func export(_ data: BackupDocument, engine: PlanningEngine) -> String {
        func domain(_ id: String) -> String { data.domains.first { $0.id == id }?.key ?? id }
        var rows = [header]
        rows += data.goals.map { ["goal", $0.id, CSV.safeCell($0.title), domain($0.domainIDs.first ?? ""), String($0.target), $0.unit, engine.key($0.start), engine.key($0.end), "none"] }
        rows += data.tasks.map { ["task", $0.id, CSV.safeCell($0.title), domain($0.domainID), String($0.target), $0.unit, engine.key($0.start), engine.key($0.end ?? engine.addingDays(365, to: $0.start)), $0.recurrence] }
        return CSV.encode(rows)
    }
}
