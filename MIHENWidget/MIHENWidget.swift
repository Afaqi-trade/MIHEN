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
    @Environment(\.widgetFamily) private var family
    let entry: TodayEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MİHEN").font(.headline)
            if let snapshot = entry.snapshot {
                let today = PlanningEngine(timeZone: TimeZone(identifier: snapshot.timeZoneID) ?? .current).key(entry.date)
                if snapshot.locked { Label(text("unlock", snapshot), systemImage: "lock") }
                else if snapshot.day == today {
                    Text(snapshot.planned > 0 ? "\(snapshot.completed) / \(snapshot.planned) " + text("tasks.completed", snapshot) : text("today.first.title", snapshot)).font(.headline)
                    ProgressView(value: snapshot.planned > 0 ? Double(snapshot.completed) / Double(snapshot.planned) : 0)
                    if let next = snapshot.nextTitle { Text(next).font(.caption).lineLimit(2) }
                    else { Text(text("today", snapshot)).font(.caption) }
                    HStack {
                        Link(destination:URL(string:"mihen://water?day="+snapshot.day)!) { Label(text("water.widget",snapshot),systemImage:"drop").font(.caption) }
                        if family != .systemSmall { Link(destination:URL(string:"mihen://add-task")!) { Label(text("task.new",snapshot),systemImage:"plus.circle").font(.caption) } }
                    }
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
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { PrayerWidgetView(entry: $0) }
        .configurationDisplayName(LocalizedStringKey("prayer.times"))
            .description(LocalizedStringKey("prayer.source"))
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}
struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PrayerEntry
    private var settings: PrayerSettings {
        PrayerSettingsStore.read() ?? .init(latitude: 41.0082, longitude: 28.9784, timeZoneID: "Europe/Istanbul", method: "turkey", hanafi: false)
    }
    var body: some View {
        let schedule = settings.schedule(on: entry.date)
        let next = schedule.first { $0.key != "sunrise" && $0.date > entry.date }?.key
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey("prayer.times")).font(.headline).lineLimit(1).minimumScaleFactor(0.8)
            if schedule.isEmpty {
                Text(LocalizedStringKey("prayer.unavailable")).font(.caption)
            } else if family == .systemSmall {
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], alignment: .leading, spacing: 5) {
                    ForEach(schedule, id: \.key) { item in prayerItem(item.key, item.date, next == item.key) }
                }
            } else {
                HStack(alignment: .top, spacing: 2) {
                    ForEach(schedule, id: \.key) { item in prayerItem(item.key, item.date, next == item.key).frame(maxWidth: .infinity, alignment: .leading) }
                }.frame(maxHeight: .infinity, alignment: .center)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .containerBackground(for: .widget) { Color(red: 11/255, green: 34/255, blue: 68/255) }
            .foregroundStyle(.white).widgetURL(URL(string: "mihen://prayers"))
    }
    private func prayerItem(_ key: String, _ date: Date, _ upcoming: Bool) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(LocalizedStringKey("prayer." + key)).font(.caption2).lineLimit(1).minimumScaleFactor(0.75)
            Text(settings.displayTime(date)).font(.system(.caption, design: .rounded, weight: upcoming ? .bold : .medium)).monospacedDigit()
        }.foregroundStyle(upcoming ? Color(red: 0.68, green: 0.92, blue: 0.72) : .white)
    }
}
@main struct MIHENWidgets: WidgetBundle {
    var body: some Widget { MIHENWidget(); PrayerWidget() }
}
