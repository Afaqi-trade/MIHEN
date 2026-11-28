import SwiftUI

struct CalendarScreen: View {
    @Environment(AppStore.self) private var store
    @State private var selected = Date()
    @State private var scope = "month"
    @State private var addEvent = false
    @State private var editingEvent: CalendarEventRecord?
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: PrayerTimesScreen()) {
                    HStack {
                        Label(store.t("prayer.times"), systemImage: "sun.horizon.fill")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.semibold))
                    }.mihenCard()
                }.buttonStyle(.plain).accessibilityIdentifier("calendar.prayer")
                Picker(store.t("calendar.view"), selection: $scope) { ForEach(["day", "week", "month"], id: \.self) { Text(store.t($0)).tag($0) } }.pickerStyle(.segmented)
                if scope == "month" { CalendarMonthGrid(selected: $selected) }
                else {
                    DatePicker(store.t("date"), selection: $selected, displayedComponents: .date)
                    if scope == "week" {
                        let interval = store.engine.calendar.dateInterval(of: .weekOfYear, for: selected)!
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(store.engine.days(from: interval.start, through: store.engine.addingDays(6, to: interval.start)), id: \.self) { date in
                                    Button { selected = date } label: {
                                        VStack { Text(date, format: .dateTime.weekday(.abbreviated)); Text(date, format: .dateTime.day()); Text(hijri(date, short: true)).font(.caption2) }.padding(10).background(store.engine.key(date) == store.engine.key(selected) ? Color.mihenGreen.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }
                Text(selected, format: .dateTime.weekday(.wide).day().month(.wide)).font(.title3.bold())
                Text(store.t("calendar.hijri") + ": " + hijri(selected)).font(.subheadline).foregroundStyle(.secondary)
                ForEach(store.occurrences(on: selected)) { OccurrenceRow(occurrence: $0) }
                if store.occurrences(on: selected).isEmpty { Text(store.t("empty.tasks")).foregroundStyle(.secondary) }
                Text(store.t("events")).font(.headline)
                ForEach(eventsOnDay) { event in
                    Button { editingEvent = event } label: {
                        VStack(alignment: .leading) {
                            Text(event.title).font(.headline)
                            Text(event.date, format: .dateTime.hour().minute())
                            Text(event.notes).font(.caption)
                        }.mihenCard()
                    }.buttonStyle(.plain)
                }
                ForEach(store.data.goals.filter { !$0.archived && store.engine.key($0.end) == store.engine.key(selected) }) { goal in GoalLink(goal: goal).mihenCard() }
                let fasts = store.data.fasts.filter { store.engine.key($0.date) == store.engine.key(selected) }
                if !fasts.isEmpty { Text(store.t("calendar.fasting")).font(.headline) }
                ForEach(fasts) { fast in
                    Label(fast.title + " · " + store.t(fast.status == "completed" ? "fast.observed" : fast.status == "planned" ? "fast.planned" : fast.status), systemImage: "moon").mihenCard()
                }
                let nutritionPlans = store.data.nutritionPlans.filter { store.engine.key($0.date) == store.engine.key(selected) }
                let activities = store.data.effectiveActivities(engine: store.engine).filter { store.engine.key($0.date) == store.engine.key(selected) }
                let readings = store.data.readings.filter { store.engine.key($0.date) == store.engine.key(selected) }
                if !nutritionPlans.isEmpty || !activities.isEmpty || !readings.isEmpty { Text(store.t("calendar.otherRecords")).font(.headline) }
                ForEach(nutritionPlans) { plan in
                    let name = plan.title.isEmpty ? store.t("activity." + plan.kind) : plan.title
                    Label(store.t("nutrition.planned") + " · " + name + " · " + plan.amount.formatted(.number.locale(store.locale)) + " " + store.t(plan.unit), systemImage: "calendar.badge.clock").mihenCard()
                }
                ForEach(activities) { activity in
                    Label(store.t("calendar.recorded") + " · " + store.t("activity." + activity.kind) + " · " + activity.amount.formatted(.number.locale(store.locale)) + " " + store.reportUnit(activity.unit), systemImage: "checkmark.circle").mihenCard()
                }
                ForEach(readings) { reading in
                    Label(store.t("calendar.recorded") + " · " + store.t("report.reading") + " · \(reading.pages) " + store.t("pages"), systemImage: "book").mihenCard()
                }
            }.padding()
        }.background(Color.mihenBackground).navigationTitle(store.t("calendar"))
            .toolbar { Button { addEvent = true } label: { Image(systemName: "plus") }.accessibilityLabel(store.t("event.new")) }
            .sheet(isPresented: $addEvent) { EventEditor(date: selected) }
            .sheet(item: $editingEvent) { EventEditor(event: $0) }
            .task(id: store.engine.key(selected)) {
                let planner = store.engine
                store.change { planner.materialize(&$0, from: selected, through: selected) }
            }
    }
    private var eventsOnDay: [CalendarEventRecord] {
        store.data.events.filter {
            let task = PlannedTaskRecord(title: $0.title, start: $0.date, recurrence: $0.recurrence)
            return store.engine.isDue(task, on: selected)
        }.sorted { $0.date < $1.date }
    }
    private func hijri(_ date: Date, short: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.locale = store.locale; formatter.calendar = store.engine.hijriCalendar; formatter.timeZone = store.engine.timeZone
        if short { formatter.setLocalizedDateFormatFromTemplate("d MMM") } else { formatter.dateStyle = .long }
        return formatter.string(from: store.engine.addingDays(store.preferences.hijriOffset, to: date))
    }
}

private struct CalendarMonthGrid: View {
    @Environment(AppStore.self) private var store
    @Binding var selected: Date
    private var month: DateInterval { store.engine.calendar.dateInterval(of: .month, for: selected)! }
    private var offset: Int {
        let calendar = store.engine.calendar
        return (calendar.component(.weekday, from: month.start) - calendar.firstWeekday + 7) % 7
    }
    private var monthDays: [Date] { store.engine.days(from: month.start, through: store.engine.addingDays(-1, to: month.end)) }
    private var symbols: [String] {
        let calendar = store.engine.calendar, values = calendar.veryShortWeekdaySymbols, first = calendar.firstWeekday - 1
        return Array(values[first...] + values[..<first])
    }
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(store.t("calendar.previousMonth"))
                Spacer()
                Text(month.start, format: .dateTime.month(.wide).year()).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(store.t("calendar.nextMonth"))
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 4) {
                ForEach(0..<7, id: \.self) { index in Text(symbols[index]).font(.caption.weight(.semibold)).frame(maxWidth: .infinity) }
                ForEach(0..<offset, id: \.self) { _ in Color.clear.frame(height: 1).accessibilityHidden(true) }
                ForEach(monthDays, id: \.self) { day in
                    Button { selected = day } label: {
                        VStack(spacing: 2) {
                            Text(String(store.engine.calendar.component(.day, from: day))).font(.body)
                            Text(String(store.engine.hijriCalendar.component(.day, from: store.engine.addingDays(store.preferences.hijriOffset, to: day)))).font(.caption2).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity, minHeight: 44)
                            .background(store.engine.key(day) == store.engine.key(selected) ? Color.mihenGreen.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 10))
                    }.buttonStyle(.plain)
                        .accessibilityLabel(accessibilityDate(day))
                        .accessibilityAddTraits(store.engine.key(day) == store.engine.key(selected) ? .isSelected : [])
                        .accessibilityIdentifier("calendar.day." + store.engine.key(day))
                }
            }
            Text(store.t("calendar.hijri.legend")).font(.caption).foregroundStyle(.secondary)
        }
    }
    private func changeMonth(_ value: Int) {
        if let date = store.engine.calendar.date(byAdding: .month, value: value, to: month.start) { selected = date }
    }
    private func accessibilityDate(_ day: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = store.locale; formatter.timeZone = store.engine.timeZone
        formatter.calendar = store.engine.calendar; formatter.dateStyle = .long
        let gregorian = formatter.string(from: day)
        formatter.calendar = store.engine.hijriCalendar
        let hijri = formatter.string(from: store.engine.addingDays(store.preferences.hijriOffset, to: day))
        return gregorian + ", " + store.t("calendar.hijri") + ": " + hijri
    }
}
struct EventEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: CalendarEventRecord
    @State private var deleting = false
    @State private var appleCalendar = false
    init(event: CalendarEventRecord? = nil, date: Date = Date()) {
        _draft = State(initialValue: event ?? .init(date: date, end: date))
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("title"), text: $draft.title).autocorrectionDisabled()
                DatePicker(store.t("start.date"), selection: $draft.date)
                DatePicker(store.t("end.date"), selection: $draft.end)
                Picker(store.t("recurrence"), selection: $draft.recurrence) { ForEach(Recurrence.allCases, id: \.rawValue) { Text(store.t($0.rawValue)).tag($0.rawValue) } }
                Button(store.t("calendar.apple.export")) { appleCalendar = true }.disabled(draft.title.isEmpty || draft.end < draft.date)
                Text(store.t("calendar.apple.explanation")).font(.footnote)
                TextEditor(text: $draft.notes).frame(minHeight: 80).accessibilityLabel(store.t("notes"))
                if store.data.events.contains(where: { $0.id == draft.id }) { Button(store.t("delete"), role: .destructive) { deleting = true } }
            }.keyboardDone().navigationTitle(store.t("event.new"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        if store.change({ data in if let i = data.events.firstIndex(where: { $0.id == draft.id }) { data.events[i] = draft } else { data.events.append(draft) } }) { dismiss() }
                    }.disabled(draft.title.isEmpty || draft.end < draft.date) }
                }
                .sheet(isPresented: $appleCalendar) { AppleCalendarEditor(record: draft) }
                .confirmationDialog(store.t("delete.confirm"), isPresented: $deleting) { Button(store.t("delete"), role: .destructive) { if store.change({ $0.events.removeAll { $0.id == draft.id } }) { dismiss() } } }
        }
    }
}
