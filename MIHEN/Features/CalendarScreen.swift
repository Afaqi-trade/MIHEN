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
                Picker(store.t("calendar.view"), selection: $scope) { ForEach(["day", "week", "month"], id: \.self) { Text(store.t($0)).tag($0) } }.pickerStyle(.segmented)
                if scope == "month" { DatePicker(store.t("date"), selection: $selected, displayedComponents: .date).datePickerStyle(.graphical) }
                else {
                    DatePicker(store.t("date"), selection: $selected, displayedComponents: .date)
                    if scope == "week" {
                        let interval = store.engine.calendar.dateInterval(of: .weekOfYear, for: selected)!
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(store.engine.days(from: interval.start, through: store.engine.addingDays(6, to: interval.start)), id: \.self) { date in
                                    Button { selected = date } label: {
                                        VStack { Text(date, format: .dateTime.weekday(.abbreviated)); Text(date, format: .dateTime.day()) }.padding(10).background(store.engine.key(date) == store.engine.key(selected) ? Color.mihenGreen.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }
                }
                Text(selected, format: .dateTime.weekday(.wide).day().month(.wide)).font(.title3.bold())
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
                ForEach(store.data.fasts.filter { store.engine.key($0.date) == store.engine.key(selected) }) { fast in Label(fast.title + " · " + store.t(fast.status), systemImage: "moon").mihenCard() }
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
