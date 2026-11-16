import SwiftUI

struct RoutinesScreen: View {
    @Environment(AppStore.self) private var store
    @State private var adding = false
    @State private var editing: RoutineRecord?
    @State private var changing: RoutineRecord?
    @State private var removing: RoutineRecord?
    private func tasks(_ id: String) -> [PlannedTaskRecord] {
        let ids = Set(store.data.routineItems.filter { $0.routineID == id }.map(\.taskID))
        return store.data.tasks.filter { ids.contains($0.id) }
    }
    var body: some View {
        List {
            if store.data.routines.isEmpty {
                Text(store.t("routine.empty"))
                Button(store.t("routine.new")) { adding = true }.buttonStyle(.borderedProminent).accessibilityIdentifier("routine.new")
            }
            ForEach(store.data.routines) { routine in
                Section {
                    let members = tasks(routine.id)
                    let paused = !members.isEmpty && members.allSatisfy(\.archived)
                    if paused { Text(store.t("routine.paused")).foregroundStyle(.secondary) }
                    ForEach(store.data.routineItems.filter { $0.routineID == routine.id }.sorted { $0.rank < $1.rank }) { item in
                        if let occurrence = store.occurrences(on: Date()).first(where: { $0.taskID == item.taskID }), !paused {
                            OccurrenceRow(occurrence: occurrence)
                        } else if let task = store.data.tasks.first(where: { $0.id == item.taskID }) {
                            Text(store.taskTitle(task.title)).foregroundStyle(.secondary)
                        }
                    }
                    Menu {
                        Button(store.t("edit")) { editing = routine }
                        Button(store.t(paused ? "routine.resume" : "routine.pause")) { changing = routine }
                        Button(store.t("routine.remove"), role: .destructive) { removing = routine }
                    } label: { Label(store.t("routine.manage"), systemImage: "ellipsis.circle") }
                } header: { Text(routine.title).accessibilityIdentifier("routine.group." + routine.id) }
            }
        }.buttonStyle(.borderless).navigationTitle(store.t("routines"))
            .toolbar { Button { adding = true } label: { Image(systemName: "plus") }.accessibilityLabel(store.t("routine.new")).accessibilityIdentifier("routine.add") }
            .sheet(isPresented: $adding) { RoutineEditor() }
            .sheet(item: $editing) { RoutineEditor(routine: $0) }
            .confirmationDialog(store.t("routine.pause.confirm"), isPresented: Binding(get: { changing != nil }, set: { if !$0 { changing = nil } })) {
                Button(store.t("continue")) {
                    guard let routine = changing else { return }
                    let members = tasks(routine.id), resume = !members.isEmpty && members.allSatisfy(\.archived)
                    let engine = store.engine
                    store.change { try engine.changeRoutineRepetitions(routine.id, resume: resume, on: Date(), in: &$0) }
                    changing = nil
                }
            }
            .confirmationDialog(store.t("routine.remove"), isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } })) {
                Button(store.t("routine.remove"), role: .destructive) {
                    guard let id = removing?.id else { return }
                    store.change { data in
                        data.routineItems.removeAll { $0.routineID == id }; data.routines.removeAll { $0.id == id }
                        data.notificationPreferences.removeAll { $0.kind == "routine." + id }
                    }; removing = nil
                }
            }
    }
}

struct RoutineEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: RoutineRecord
    @State private var selected: [String] = []
    @State private var addStep = false
    @State private var editingStep: PlannedTaskRecord?
    @State private var previousTasks = Set<String>()
    @State private var reminder = false
    @State private var reminderTime = Date()
    init(routine: RoutineRecord? = nil) { _draft = State(initialValue: routine ?? .init(domainID: "health")) }
    var body: some View {
        NavigationStack {
            Form {
                Section(store.t("routine.new")) {
                    TextField(store.t("title"), text: $draft.title).accessibilityIdentifier("routine.title")
                    Picker(store.t("area"), selection: $draft.domainID) { ForEach(store.data.domains) { Text(store.title($0.id)).tag($0.id) } }
                    if draft.title.isEmpty {
                        HStack { Button(store.t("routine.morning")) { draft.title = store.t("routine.morning") }; Button(store.t("routine.evening")) { draft.title = store.t("routine.evening") } }.buttonStyle(.borderless)
                    }
                }
                Section(store.t("routine.steps")) {
                    Text(store.t("routine.schedule.help")).font(.footnote)
                    ForEach(selected, id: \.self) { id in
                        if let task = store.data.tasks.first(where: { $0.id == id }) {
                            Button { editingStep = task } label: { VStack(alignment: .leading) { Text(store.taskTitle(task.title)); Text(store.t(task.recurrence)).font(.caption).foregroundStyle(.secondary) } }
                        }
                    }.onMove { selected.move(fromOffsets: $0, toOffset: $1) }.onDelete { selected.remove(atOffsets: $0) }
                    Button(store.t("routine.step.add")) { previousTasks = Set(store.data.tasks.map(\.id)); addStep = true }.accessibilityIdentifier("routine.step.add")
                }
                Section(store.t("routine.existing")) {
                    ForEach(store.data.tasks.filter { !$0.archived || selected.contains($0.id) }) { task in
                        Toggle(store.taskTitle(task.title), isOn: Binding(get: { selected.contains(task.id) }, set: { if $0 { if !selected.contains(task.id) { selected.append(task.id) } } else { selected.removeAll { $0 == task.id } } }))
                    }
                }
                Section(store.t("notifications")) {
                    Toggle(store.t("routine.reminder"), isOn: $reminder)
                    if reminder { DatePicker(store.t("reminder.time"), selection: $reminderTime, displayedComponents: .hourAndMinute) }
                    if !store.preferences.remindersEnabled { Text(store.t("reminder.global.off")).font(.footnote) }
                }
            }.keyboardDone().navigationTitle(store.t("routine.new"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .primaryAction) { EditButton() }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(store.t("save")) {
                            let parts = store.engine.calendar.dateComponents([.hour, .minute], from: reminderTime)
                            if store.change({ data in
                                if let i = data.routines.firstIndex(where: { $0.id == draft.id }) { data.routines[i] = draft } else { data.routines.append(draft) }
                                data.routineItems.removeAll { $0.routineID == draft.id }
                                for (rank,id) in selected.enumerated() { data.routineItems.append(.init(routineID: draft.id, taskID: id, rank: rank)) }
                                data.notificationPreferences.removeAll { $0.kind == "routine." + draft.id }
                                if reminder { data.notificationPreferences.append(.init(kind: "routine." + draft.id, enabled: true, hour: parts.hour ?? 9, minute: parts.minute ?? 0)) }
                            }) { dismiss() }
                        }.accessibilityIdentifier("routine.save").disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selected.isEmpty)
                    }
                }
                .onAppear {
                    selected = store.data.routineItems.filter { $0.routineID == draft.id }.sorted { $0.rank < $1.rank }.map(\.taskID)
                    if let pref = store.data.notificationPreferences.first(where: { $0.kind == "routine." + draft.id }) {
                        reminder = pref.enabled
                        reminderTime = store.engine.calendar.date(bySettingHour: pref.hour, minute: pref.minute, second: 0, of: Date()) ?? Date()
                    }
                }
                .sheet(item: $editingStep) { TaskEditor(task: $0) }
                .sheet(isPresented: $addStep, onDismiss: {
                    for task in store.data.tasks where !previousTasks.contains(task.id) && !selected.contains(task.id) { selected.append(task.id) }
                }) { TaskEditor(domainID: draft.domainID, routineMode: true) }
        }
    }
}

struct WeeklyPlanScreen: View {
    @Environment(AppStore.self) private var store
    @State private var selected = Date()
    @State private var weeklyNote = ""
    @State private var deciding = false
    private var days: [Date] {
        let start = store.engine.calendar.dateInterval(of: .weekOfYear, for: selected)!.start
        return (0..<7).map { store.engine.addingDays($0, to: start) }
    }
    private var rows: [TaskOccurrenceRecord] { store.data.occurrences.filter { $0.day >= store.engine.key(days[0]) && $0.day <= store.engine.key(days[6]) && !["cancelled","moved","skipped"].contains($0.status) } }
    var body: some View {
        List {
            Section {
                HStack {
                    Button { selected = store.engine.addingDays(-7, to: selected) } label: { Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(store.t("week.previous"))
                    Spacer(); Text(days[0], format: .dateTime.day().month()); Text(" - "); Text(days[6], format: .dateTime.day().month()); Spacer()
                    Button { selected = store.engine.addingDays(7, to: selected) } label: { Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(store.t("week.next"))
                }.buttonStyle(.borderless)
                DatePicker(store.t("date"), selection: $selected, displayedComponents: .date)
                let minutes = rows.filter { $0.unit == "minutes" }.reduce(0) { $0 + $1.target }
                Text(store.t("week.knownTime") + ": " + minutes.formatted(.number.locale(store.locale)) + " " + store.t("minutes"))
                Text(store.t("week.withoutTime") + ": \(rows.filter { $0.unit != "minutes" }.count)").font(.caption)
            }
            Section(store.t("week.intention")) {
                TextField(store.t("week.intention.help"), text: $weeklyNote, axis: .vertical).accessibilityIdentifier("weekly.note")
                Button(store.t("save")) {
                    let start = days[0], end = store.engine.addingDays(7, to: start)
                    store.change { data in
                        if let i = data.journals.firstIndex(where: { $0.kind == "weekly" && $0.date >= start && $0.date < end && $0.domainID == nil }) { data.journals[i].text = weeklyNote }
                        else { data.journals.append(.init(date: start, kind: "weekly", text: weeklyNote)) }
                    }
                }.disabled(weeklyNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            ForEach(days, id: \.self) { day in
                Section {
                    let items = store.occurrences(on: day).filter { !["cancelled","moved","skipped"].contains($0.status) }
                    if items.isEmpty { Text(store.t("week.room")).font(.caption).foregroundStyle(.secondary) }
                    ForEach(items) { OccurrenceRow(occurrence: $0) }
                } header: { Text(day, format: .dateTime.weekday(.wide).day().month()) }
            }
            Section {
                Button(store.t("week.decide")) { deciding = true }
                DisclosureGroup(store.t("week.backlog")) {
                    let lower = store.engine.key(store.engine.addingDays(-30, to: days[0]))
                    let upper = min(store.engine.key(days[0]), store.engine.key(Date()))
                    ForEach(store.data.occurrences.filter { $0.day >= lower && $0.day < upper && ["planned","partial"].contains($0.status) }.sorted { $0.day > $1.day }) { row in
                        VStack(alignment: .leading) { Text(row.day).font(.caption); OccurrenceRow(occurrence: row) }
                    }
                    Text(store.t("week.backlog.help")).font(.footnote)
                }
                NavigationLink(destination: ReportsScreen()) { Text(store.t("reports")) }
                NavigationLink(destination: JournalScreen()) { Text(store.t("reviews")) }
            }
        }.navigationTitle(store.t("weekly.plan"))
            .sheet(isPresented: $deciding) { WeeklyDecisionScreen(rows: rows.filter { ["planned","partial"].contains($0.status) }) }
            .task(id: store.engine.key(days[0])) {
                let engine = store.engine, start = days[0], end = days[6]
                store.change { engine.materialize(&$0, from: start, through: end) }
                weeklyNote = store.data.journals.first { $0.kind == "weekly" && $0.domainID == nil && $0.date >= start && $0.date < engine.addingDays(7, to: start) }?.text ?? ""
            }
    }
}
