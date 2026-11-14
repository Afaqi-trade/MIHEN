import Foundation
import UserNotifications

@MainActor enum ReminderService {
    static func enable() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
    static func isQuiet(hour: Int, start: Int, end: Int) -> Bool {
        start == end ? false : start < end ? hour >= start && hour < end : hour >= start || hour < end
    }
    static func reschedule(_ document: BackupDocument) async throws {
        let center = UNUserNotificationCenter.current()
        // A full reconciliation removes outdated task and deadline reminders before rebuilding.
        try Task.checkCancellation()
        center.removeAllPendingNotificationRequests()
        guard let p = document.preferences.first, p.remindersEnabled else { return }
        let settings = await center.notificationSettings()
        try Task.checkCancellation()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
        let engine = PlanningEngine(timeZone: TimeZone(identifier: p.timeZoneID) ?? .current, hijriOffset: p.hijriOffset)
        let now = Date()
        var requests: [(String, String, Date)] = []
        func title(_ key: String) -> String { Localization.text(key, language: p.language) }
        for day in engine.days(from: now, through: engine.addingDays(6, to: now)) {
            let fire = engine.calendar.date(bySettingHour: p.reminderHour, minute: 0, second: 0, of: day)!
            if fire > now { requests.append(("summary-\(engine.key(day))", title("reminder.summary"), fire)) }
            for task in document.tasks where engine.isDue(task, on: day, restWeekdays: p.restWeekdays) {
                let occurrence = document.occurrences.first { $0.taskID == task.id && $0.day == engine.key(day) }
                guard occurrence == nil || ["planned", "partial"].contains(occurrence!.status) else { continue }
                if fire > now { requests.append(("task-\(task.id)-\(engine.key(day))", p.lockEnabled ? title("reminder.task") : title(task.title), fire)) }
            }
            for pref in document.notificationPreferences where pref.enabled && ["evening", "weekly"].contains(pref.kind) {
                if pref.kind == "weekly" && engine.calendar.component(.weekday, from: day) != 1 { continue }
                let date = engine.calendar.date(bySettingHour: pref.hour, minute: pref.minute, second: 0, of: day)!
                if date > now { requests.append(("\(pref.id)-\(engine.key(day))", title("reminder.review"), date)) }
            }
        }
        for goal in document.goals where !goal.archived && goal.end > now {
            requests.append(("goal-\(goal.id)", p.lockEnabled ? title("reminder.task") : goal.title, goal.end))
        }
        for item in document.memorization {
            if let date = engine.nextReview(item, reviews: document.memorizationReviews), date > now {
                requests.append(("review-\(item.id)", p.lockEnabled ? title("reminder.task") : item.title, date))
            }
        }
        for fast in document.fasts where fast.status == "planned" && fast.date > now { requests.append(("fast-\(fast.id)", title("reminder.fast"), fast.date)) }
        for event in document.events where event.date > now { requests.append(("event-\(event.id)", p.lockEnabled ? title("reminder.task") : event.title, event.date)) }
        for (id, text, date) in requests.sorted(by: { $0.2 < $1.2 }).prefix(60) {
            try Task.checkCancellation()
            let hour = engine.calendar.component(.hour, from: date)
            guard !isQuiet(hour: hour, start: p.quietStart, end: p.quietEnd) else { continue }
            let content = UNMutableNotificationContent()
            content.title = "MİHEN"
            content.body = text
            content.sound = .default
            var components = engine.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.timeZone = engine.timeZone
            components.calendar = engine.calendar
            try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)))
        }
    }
}
