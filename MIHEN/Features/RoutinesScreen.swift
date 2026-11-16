import SwiftUI

struct RoutinesScreen: View {
    @Environment(AppStore.self) private var store
    @State private var title = ""
    @State private var domain = "health"
    @State private var selected = Set<String>()
    var body: some View {
        List {
            Section(store.t("routine.new")) {
                TextField(store.t("title"), text: $title).accessibilityIdentifier("routine.title")
                Picker(store.t("area"), selection: $domain) {
                    ForEach(store.data.domains) { Text(store.title($0.id)).tag($0.id) }
                }
                ForEach(store.data.tasks.filter { !$0.archived }) { task in
                    Toggle(store.taskTitle(task.title), isOn: Binding(get: { selected.contains(task.id) }, set: { if $0 { selected.insert(task.id) } else { selected.remove(task.id) } }))
                }
                Button(store.t("save")) {
                    let routine = RoutineRecord(title: title, domainID: domain)
                    let tasks = store.data.tasks.filter { selected.contains($0.id) }
                    if store.change({ document in
                        document.routines.append(routine)
                        for (rank, task) in tasks.enumerated() { document.routineItems.append(.init(routineID: routine.id, taskID: task.id, rank: rank)) }
                    }) { title = ""; selected = [] }
                }.accessibilityIdentifier("routine.save").disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selected.isEmpty)
            }
            ForEach(store.data.routines) { routine in
                Section {
                    ForEach(store.data.routineItems.filter { $0.routineID == routine.id }.sorted { $0.rank < $1.rank }) { item in
                        if let occurrence = store.occurrences(on: Date()).first(where: { $0.taskID == item.taskID }) {
                            OccurrenceRow(occurrence: occurrence)
                        } else if let task = store.data.tasks.first(where: { $0.id == item.taskID }) {
                            Text(store.taskTitle(task.title)).foregroundStyle(.secondary)
                        }
                    }
                    Button(store.t("routine.remove"), role: .destructive) {
                        store.change { data in
                            data.routineItems.removeAll { $0.routineID == routine.id }
                            data.routines.removeAll { $0.id == routine.id }
                        }
                    }
                } header: { Text(routine.title).accessibilityIdentifier("routine.group." + routine.id) }
            }
        }.keyboardDone().navigationTitle(store.t("routines"))
    }
}

struct WeeklyPlanScreen: View {
    @Environment(AppStore.self) private var store
    @State private var selected = Date()
    private var days: [Date] {
        let start = store.engine.calendar.dateInterval(of: .weekOfYear, for: selected)!.start
        return (0..<7).map { store.engine.addingDays($0, to: start) }
    }
    var body: some View {
        List {
            DatePicker(store.t("date"), selection: $selected, displayedComponents: .date)
            Section(store.t("overdue")) {
                ForEach(store.data.occurrences.filter { $0.day < store.engine.key(Date()) && ["planned", "partial"].contains($0.status) }.sorted { $0.day > $1.day }) { row in
                    VStack(alignment: .leading) { Text(row.day).font(.caption); OccurrenceRow(occurrence: row) }
                }
            }
            ForEach(days, id: \.self) { day in
                Section {
                    ForEach(store.occurrences(on: day)) { OccurrenceRow(occurrence: $0) }
                } header: { Text(day, format: .dateTime.weekday(.wide).day().month()) }
            }
        }.navigationTitle(store.t("weekly.plan"))
            .task(id: store.engine.key(days[0])) {
                let engine = store.engine
                store.change { engine.materialize(&$0, from: days[0], through: days[6]) }
            }
    }
}
