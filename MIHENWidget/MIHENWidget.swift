import SwiftUI
import WidgetKit

struct TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}
struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry { .init(date: Date(), snapshot: nil) }
    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) { completion(.init(date: Date(), snapshot: SharedWidgetStore.read())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date()
        completion(Timeline(entries: [.init(date: now, snapshot: SharedWidgetStore.read())], policy: .after(now.addingTimeInterval(900))))
    }
}
struct TodayWidgetView: View {
    let entry: TodayEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MİHEN").font(.headline)
            if let snapshot = entry.snapshot {
                let today = PlanningEngine(timeZone: TimeZone(identifier: snapshot.timeZoneID) ?? .current).key(entry.date)
                if snapshot.locked { Label(text("unlock", snapshot), systemImage: "lock") }
                else if snapshot.day == today {
                    Text("\(snapshot.completed) / \(snapshot.planned)").font(.largeTitle.bold())
                    ProgressView(value: snapshot.planned > 0 ? Double(snapshot.completed) / Double(snapshot.planned) : 0)
                    if let next = snapshot.nextTitle { Text(next).font(.caption).lineLimit(2) }
                    else { Text(text("today", snapshot)).font(.caption) }
                } else { Text(text("widget.open", snapshot)) }
            } else { Text(LocalizedStringKey("widget.open")) }
        }.containerBackground(for: .widget) { Color(red: 11/255, green: 34/255, blue: 68/255) }
            .foregroundStyle(.white).tint(.white).widgetURL(URL(string: "mihen://today"))
    }
    private func text(_ key: String, _ snapshot: WidgetSnapshot) -> String { Localization.text(key, language: snapshot.language) }
}
struct MIHENWidget: Widget {
    let kind = "MIHENToday"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { TodayWidgetView(entry: $0) }
            .configurationDisplayName("MİHEN")
            .description(LocalizedStringKey("widget.description"))
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PrayerEntry: TimelineEntry {
    let date: Date
}
struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry { .init(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) { completion(.init(date: Date())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        completion(.init(entries: [.init(date: now)], policy: .after(now.addingTimeInterval(900))))
    }
}
struct PrayerWidget: Widget {
    let kind = "MIHENPrayer"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            VStack(alignment: .leading, spacing: 6) {
                Text("MİHEN · Namaz / Prayer").font(.headline)
                if let settings = PrayerSettingsStore.read() {
                    let tomorrow = PlanningEngine(timeZone: TimeZone(identifier: settings.timeZoneID) ?? .current).addingDays(1, to: entry.date)
                    let schedule = settings.schedule(on: entry.date) + settings.schedule(on: tomorrow)
                    if let next = schedule.first(where: { $0.key != "sunrise" && $0.date > entry.date }) {
                        Text(LocalizedStringKey("prayer." + next.key))
                        Text(next.date, format: Date.FormatStyle(date: .omitted, time: .shortened, timeZone: TimeZone(identifier: settings.timeZoneID) ?? .current)).font(.title.bold())
                    } else { Text(LocalizedStringKey("prayer.unavailable")) }
                    Text(LocalizedStringKey("method." + settings.method)).font(.caption)
                } else { Text(LocalizedStringKey("widget.open")) }
            }.containerBackground(for: .widget) { Color(red: 11/255, green: 34/255, blue: 68/255) }
                .foregroundStyle(.white).widgetURL(URL(string: "mihen://prayers"))
        }.configurationDisplayName("MİHEN Namaz / Prayer")
            .description(LocalizedStringKey("prayer.source"))
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
@main struct MIHENWidgets: WidgetBundle {
    var body: some Widget { MIHENWidget(); PrayerWidget() }
}
