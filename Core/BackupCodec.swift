import Foundation

public enum BackupCodec {
    public static let maximumBytes = 10 * 1024 * 1024
    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    public static func encode(_ document: BackupDocument) throws -> Data {
        try validate(document)
        let bytes = try encoder().encode(document)
        guard bytes.count <= maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        return bytes
    }
    public static func decode(_ bytes: Data) throws -> BackupDocument {
        guard bytes.count <= maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        let document = try decoder().decode(BackupDocument.self, from: bytes)
        try validate(document)
        return document
    }
    public static func validate(_ data: BackupDocument) throws {
        func check(_ condition: Bool, _ message: String = "validation.data") throws {
            if !condition { throw PlanError.invalid(message) }
        }
        func unique<T: Identifiable>(_ items: [T]) throws where T.ID == String {
            try check(items.count <= 100_000)
            try check(Set(items.map(\.id)).count == items.count, "validation.duplicates")
            try check(items.allSatisfy { !$0.id.isEmpty && $0.id.count <= 150 })
        }
        try validateUnique(data)
        try check(data.version == 1, "validation.version")
        try check(data.preferences.count == 1)
        try check(data.domains.count == 8 && Set(data.domains.map(\.key)) == Set(LifeArea.allCases.map(\.rawValue)))
        let domainIDs = Set(data.domains.map(\.id)), goalIDs = Set(data.goals.map(\.id))
        let taskIDs = Set(data.tasks.map(\.id)), khatmIDs = Set(data.khatms.map(\.id))
        let memorizationIDs = Set(data.memorization.map(\.id)), routineIDs = Set(data.routines.map(\.id))
        let subIDs = Set(data.subcategories.map(\.id))
        let engine = PlanningEngine(timeZone: TimeZone(secondsFromGMT: 0)!)
        let preferences = data.preferences[0]
        try check(["tr", "en"].contains(preferences.language) && ["system", "light", "dark"].contains(preferences.theme))
        try check(TimeZone(identifier: preferences.timeZoneID) != nil && (-2...2).contains(preferences.hijriOffset))
        try check((0...23).contains(preferences.reminderHour) && (0...23).contains(preferences.quietStart) && (0...23).contains(preferences.quietEnd))
        try check(preferences.restWeekdays.allSatisfy { (1...7).contains($0) })
        try check(preferences.name.count <= 200)
        for goal in data.goals {
            try check(!goal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && goal.title.count <= 500)
            try check(!goal.domainIDs.isEmpty && Set(goal.domainIDs).isSubset(of: domainIDs))
            try check(goal.target.isFinite && goal.target > 0 && goal.target <= 1e12 && goal.end >= goal.start && (0...2).contains(goal.priority))
            try check(["vision", "year", "quarter", "month", "week", "day"].contains(goal.horizon))
            if let parent = goal.parentID { try check(goalIDs.contains(parent) && parent != goal.id) }
            if let sub = goal.subcategoryID { try check(subIDs.contains(sub)) }
            var seen: Set<String> = [goal.id], cursor = goal.parentID
            while let id = cursor {
                try check(seen.insert(id).inserted, "validation.cycle")
                cursor = data.goals.first(where: { $0.id == id })?.parentID
            }
        }
        for task in data.tasks {
            try check(!task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && task.title.count <= 500)
            try check(domainIDs.contains(task.domainID) && task.target.isFinite && task.target > 0 && task.target <= 1e12 && (0...2).contains(task.priority))
            try check(Recurrence(rawValue: task.recurrence) != nil && (task.end == nil || task.end! >= task.start))
            try check(task.weekdays.allSatisfy { (1...7).contains($0) })
            if let goal = task.goalID { try check(goalIDs.contains(goal)) }
        }
        var occurrenceKeys = Set<String>()
        for item in data.occurrences {
            try check(taskIDs.contains(item.taskID) && domainIDs.contains(item.domainID) && engine.date(item.day) != nil)
            try check(occurrenceKeys.insert("\(item.taskID)|\(item.day)").inserted, "validation.duplicateDay")
            try check(item.target.isFinite && item.target > 0 && item.value.isFinite && item.value >= 0 && item.value <= item.target)
            try check(OccurrenceStatus(rawValue: item.status) != nil && (0...2).contains(item.priority))
            if let goal = item.goalID { try check(goalIDs.contains(goal)) }
            if let day = item.originalDay { try check(engine.date(day) != nil) }
            if item.status == "completed" { try check(item.value == item.target) }
            if item.status == "partial" { try check(item.value > 0 && item.value < item.target) }
            if item.status == "planned" { try check(item.value == 0) }
        }
        for row in data.subcategories { try check(domainIDs.contains(row.domainID) && !row.title.isEmpty) }
        for row in data.goalProgress { try check(goalIDs.contains(row.goalID) && row.amount.isFinite && row.amount >= 0 && row.amount <= 1e12) }
        for row in data.milestones { try check(goalIDs.contains(row.goalID)) }
        for row in data.projects {
            try check(domainIDs.contains(row.domainID))
            if let goal = row.goalID { try check(goalIDs.contains(goal)) }
        }
        for row in data.routines { try check(domainIDs.contains(row.domainID)) }
        for row in data.routineItems { try check(routineIDs.contains(row.routineID) && taskIDs.contains(row.taskID)) }
        for row in data.readings { try check(khatmIDs.contains(row.khatmID) && (1...100_000).contains(row.pages)) }
        for row in data.khatms {
            try check((1...100_000).contains(row.totalPages) && row.end >= row.start)
            try check(["reading", "translation", "tafsir"].contains(row.kind))
            let total = data.readings.filter { $0.khatmID == row.id }.reduce(Int64(0)) { $0 + Int64($1.pages) }
            try check(total <= Int64(row.totalPages))
            if row.completedAt != nil { try check(total == Int64(row.totalPages)) }
        }
        for row in data.readings { try check(khatmIDs.contains(row.khatmID) && (1...100_000).contains(row.pages)) }
        for row in data.memorization {
            try check(row.firstVerse > 0 && row.lastVerse >= row.firstVerse && row.lastVerse <= 10_000)
            try check(row.learnedVerses >= 0 && row.learnedVerses <= row.lastVerse - row.firstVerse + 1)
            try check(!row.intervals.isEmpty && row.intervals.allSatisfy { (1...3650).contains($0) } && (0...2).contains(row.difficulty))
        }
        for row in data.memorizationReviews { try check(memorizationIDs.contains(row.itemID) && (0...2).contains(row.difficulty)) }
        try check(Set(data.dhikr.map { "\($0.title)|\($0.day)" }).count == data.dhikr.count, "validation.duplicates")
        for row in data.dhikr { try check(!row.title.isEmpty && engine.date(row.day) != nil && row.target > 0 && row.value >= 0 && row.value <= 1_000_000) }
        for row in data.fasts { try check(!row.title.isEmpty && ["planned", "completed", "cancelled", "postponed"].contains(row.status)) }
        for row in data.events { try check(!row.title.isEmpty && row.end >= row.date && Recurrence(rawValue: row.recurrence) != nil) }
        for row in data.journals {
            if let domain = row.domainID { try check(domainIDs.contains(domain)) }
            try check(["note", "weekly", "monthly"].contains(row.kind) && row.text.count <= 100_000)
        }
        for row in data.notificationPreferences { try check((0...23).contains(row.hour) && (0...59).contains(row.minute)) }
        for row in data.activities {
            try check(domainIDs.contains(row.domainID) && row.amount.isFinite && row.amount >= 0 && row.amount <= 1e12)
            try check(["exercise", "sleep", "income", "expense", "budget", "obligation", "giving", "volunteering", "learning", "other"].contains(row.kind))
        }
        try validateUnique(data)
    }
}

public enum CSV {
    public static func encode(_ rows: [[String]]) -> String {
        rows.map { row in row.map { "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\"" }.joined(separator: ",") }.joined(separator: "\r\n")
    }
    public static func parse(_ text: String) throws -> [[String]] {
        guard text.utf8.count <= BackupCodec.maximumBytes else { throw PlanError.invalid("validation.fileSize") }
        let chars = Array(text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text)
        var rows: [[String]] = [], row: [String] = [], field = "", quoted = false, closed = false, index = 0
        while index < chars.count {
            let char = chars[index]
            if quoted {
                if char == "\"" {
                    if index + 1 < chars.count && chars[index + 1] == "\"" { field.append("\""); index += 1 }
                    else { quoted = false; closed = true }
                } else { field.append(char) }
            } else if char == "\"" {
                guard field.isEmpty && !closed else { throw PlanError.invalid("validation.csv") }
                quoted = true
            } else if char == "," {
                row.append(field); field = ""; closed = false
            } else if char == "\n" || char == "\r" || char == "\r\n" {
                row.append(field); rows.append(row); row = []; field = ""; closed = false
                if char == "\r", index + 1 < chars.count, chars[index + 1] == "\n" { index += 1 }
            } else {
                guard !closed else { throw PlanError.invalid("validation.csv") }
                field.append(char)
            }
            index += 1
        }
        guard !quoted else { throw PlanError.invalid("validation.csv") }
        if !row.isEmpty || !field.isEmpty || closed { row.append(field); rows.append(row) }
        return rows
    }
    /// Prevent spreadsheets from executing formula-like user text in human-readable exports.
    public static func safeCell(_ text: String) -> String {
        guard let first = text.trimmingCharacters(in: .whitespacesAndNewlines).first else { return text }
        return "=+-@".contains(first) ? "'" + text : text
    }
}
