import SwiftUI

struct PlanView: View {
    @Environment(AppStore.self) private var store
    @State private var addGoal = false
    var body: some View {
        List {
            Section(store.t("eight.areas")) {
                ForEach(orderedDomains) { domain in DomainNavigationRow(domain: domain) }
            }
            Section { shortcuts }
        }
        .navigationTitle(store.t("plan"))
        .toolbar {
            Button { addGoal = true } label: { Image(systemName: "plus") }
                .accessibilityLabel(store.t("goal.new")).accessibilityIdentifier("plan.add")
        }
        .sheet(isPresented: $addGoal) { GoalEditor() }
    }
    private var orderedDomains: [LifeDomainRecord] { store.data.domains.sorted { $0.rank < $1.rank } }
    @ViewBuilder private var shortcuts: some View {
        NavigationLink(destination: WeeklyPlanScreen()) { Label(store.t("weekly.plan"), systemImage: "calendar") }
        NavigationLink(destination: RoutinesScreen()) { Label(store.t("routines"), systemImage: "list.bullet") }
        NavigationLink(destination: GoalListScreen()) { Label(store.t("goals"), systemImage: "target") }
        NavigationLink(destination: TaskListScreen()) { Label(store.t("tasks.habits"), systemImage: "repeat") }
        NavigationLink(destination: SpiritualScreen()) { Label(store.t("spiritual"), systemImage: "sparkles") }.accessibilityIdentifier("plan.spiritual")
        NavigationLink(destination: JournalScreen()) { Label(store.t("reviews"), systemImage: "text.book.closed") }
    }
}
private struct DomainNavigationRow: View {
    @Environment(AppStore.self) private var store
    let domain: LifeDomainRecord
    private var count: Int { store.data.goals.filter { $0.domainIDs.contains(domain.id) && !$0.archived }.count }
    var body: some View {
        NavigationLink(destination: DomainScreen(domainID: domain.id)) {
            HStack(spacing: 14) {
                Image(systemName: LifeArea(rawValue: domain.key)?.symbol ?? "leaf")
                    .font(.title3).foregroundStyle(Color.mihenGreen).frame(width: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.title(domain.id)).font(.headline)
                    Text("\(count) " + store.t("goals")).font(.caption).foregroundStyle(.secondary)
                }
                if !domain.enabled { Image(systemName: "pause.circle").accessibilityLabel(store.t("inactive")) }
            }.padding(.vertical, 5)
        }
    }
}
struct DomainScreen: View {
    @Environment(AppStore.self) private var store
    let domainID: String
    @State private var goalEditor = false
    @State private var subcategory = ""
    @State private var vision = ""
    var body: some View {
        List {
            Section(store.t("vision")) {
                TextEditor(text: $vision).frame(minHeight: 90).accessibilityLabel(store.t("vision"))
                Button(store.t("save")) { store.change { data in if let i = data.domains.firstIndex(where: { $0.id == domainID }) { data.domains[i].vision = vision } } }
                Toggle(store.t("active"), isOn: Binding(get: { store.data.domains.first { $0.id == domainID }?.enabled ?? false }, set: { value in store.change { data in if let i = data.domains.firstIndex(where: { $0.id == domainID }) { data.domains[i].enabled = value } } }))
            }
            Section(store.t("goals")) {
                ForEach(store.data.goals.filter { $0.domainIDs.contains(domainID) && !$0.archived }) { GoalLink(goal: $0) }
                Button(store.t("goal.new")) { goalEditor = true }
            }
            Section(store.t("subcategories")) {
                ForEach(store.data.subcategories.filter { $0.domainID == domainID }) { row in
                    Text(row.title).swipeActions { Button(store.t("delete"), role: .destructive) {
                        store.change { data in
                            data.subcategories.removeAll { $0.id == row.id }
                            for i in data.goals.indices where data.goals[i].subcategoryID == row.id { data.goals[i].subcategoryID = nil }
                        }
                    } }
                }
                TextField(store.t("title"), text: $subcategory)
                Button(store.t("add")) { if store.change({ $0.subcategories.append(.init(domainID: domainID, title: subcategory)) }) { subcategory = "" } }.disabled(subcategory.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            Section {
                NavigationLink(destination: DomainActivityScreen(domainID: domainID)) { Label(store.t("activity.log"), systemImage: "list.bullet.rectangle") }
                NavigationLink(destination: ProjectsScreen(domainID: domainID)) { Label(store.t("projects"), systemImage: "folder") }
            }
            Section(store.t("notes")) {
                ForEach(store.data.journals.filter { $0.domainID == domainID }) { row in Text(row.text) }
                NavigationLink(destination: JournalScreen(domainID: domainID)) { Text(store.t("notes.reviews")) }
            }
        }.keyboardDone().navigationTitle(store.title(domainID)).navigationBarTitleDisplayMode(.inline)
            .onAppear { vision = store.data.domains.first { $0.id == domainID }?.vision ?? "" }
            .sheet(isPresented: $goalEditor) { GoalEditor(domainID: domainID) }
    }
}
struct GoalListScreen: View {
    @Environment(AppStore.self) private var store
    @State private var search = ""
    @State private var priority = -1
    @State private var horizon = "all"
    @State private var showArchived = false
    @State private var editor = false
    var body: some View {
        List {
            Picker(store.t("priority"), selection: $priority) {
                Text(store.t("all")).tag(-1)
                ForEach(0..<3) { Text(store.t("priority.\($0)")).tag($0) }
            }
            Picker(store.t("horizon"), selection: $horizon) {
                ForEach(["all", "vision", "year", "quarter", "month", "week", "day"], id: \.self) { Text(store.t($0)).tag($0) }
            }
            Toggle(store.t("archived.show"), isOn: $showArchived)
            ForEach(store.data.goals.filter { (showArchived || !$0.archived) && (priority == -1 || $0.priority == priority) && (horizon == "all" || $0.horizon == horizon) && (search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)) }.sorted { $0.priority == $1.priority ? $0.end < $1.end : $0.priority > $1.priority }) { GoalLink(goal: $0) }
        }.keyboardDone().navigationTitle(store.t("goals")).searchable(text: $search, prompt: Text(store.t("search")))
            .toolbar { Button { editor = true } label: { Image(systemName: "plus") } }
            .sheet(isPresented: $editor) { GoalEditor() }
    }
}
struct GoalLink: View {
    @Environment(AppStore.self) private var store
    let goal: GoalRecord
    var body: some View {
        NavigationLink(destination: GoalDetail(goalID: goal.id)) {
            let amount = store.engine.goalValue(goal.id, in: store.data)
            VStack(alignment: .leading, spacing: 6) {
                Text(goal.title).font(.headline)
                Text("\(amount.formatted(.number.locale(store.locale))) / \(goal.target.formatted(.number.locale(store.locale))) \(store.t(goal.unit))").font(.caption).foregroundStyle(.secondary)
                ProgressView(value: min(1, amount / goal.target))
            }.padding(.vertical, 5)
        }
    }
}
struct GoalDetail: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let goalID: String
    @State private var edit = false
    @State private var addTask = false
    @State private var delete = false
    @State private var amount = 1.0
    @State private var milestone = ""
    var body: some View {
        List {
            if let goal = store.data.goals.first(where: { $0.id == goalID }) {
                Section {
                    Text(goal.title).font(.title2.bold())
                    ForEach(goal.domainIDs, id: \.self) { Text(store.title($0)).font(.caption) }
                    Text(goal.notes)
                    Text(goal.end, format: .dateTime.day().month().year())
                    Text(store.t("daily.suggestion") + ": " + store.engine.remainingPerDay(total: goal.target, completed: store.engine.goalValue(goalID, in: store.data), start: goal.start, end: goal.end, now: Date()).formatted(.number.locale(store.locale)) + " " + store.t(goal.unit))
                    Text(store.t("pacing.explanation")).font(.footnote).foregroundStyle(.secondary)
                }
                Section(store.t("progress.add")) {
                    ValueInput(title: "amount", value: $amount)
                    Button(store.t("save")) { store.change { $0.goalProgress.append(.init(goalID: goalID, amount: amount)) } }
                    ForEach(store.data.goalProgress.filter { $0.goalID == goalID }.sorted { $0.date > $1.date }) { entry in
                        HStack { Text(entry.date, format: .dateTime.day().month()); Spacer(); Text(entry.amount.formatted(.number.locale(store.locale))) }
                            .swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.goalProgress.removeAll { $0.id == entry.id } } } }
                    }
                }
                Section(store.t("milestones")) {
                    ForEach(store.data.milestones.filter { $0.goalID == goalID }) { row in
                        Toggle(row.title, isOn: Binding(get: { row.done }, set: { value in store.change { data in if let i = data.milestones.firstIndex(where: { $0.id == row.id }) { data.milestones[i].done = value } } }))
                    }
                    TextField(store.t("title"), text: $milestone)
                    Button(store.t("add")) { if store.change({ $0.milestones.append(.init(goalID: goalID, title: milestone, due: goal.end)) }) { milestone = "" } }.disabled(milestone.isEmpty)
                }
                Section(store.t("linked.tasks")) {
                    NavigationLink(destination: GoalPlanningScreen(goalID: goalID)) { Text(store.t("goal.split")) }
                    ForEach(store.data.tasks.filter { $0.goalID == goalID }) { Text(store.taskTitle($0.title)) }
                    Button(store.t("task.new")) { addTask = true }
                }
                Section {
                    Button(store.t("edit")) { edit = true }
                    Button(store.t(goal.archived ? "unarchive" : "archive")) { store.change { data in if let i = data.goals.firstIndex(where: { $0.id == goalID }) { data.goals[i].archived.toggle() } } }
                    Button(store.t("delete"), role: .destructive) { delete = true }
                }
                .sheet(isPresented: $edit) { GoalEditor(goal: goal) }
                .sheet(isPresented: $addTask) { TaskEditor(goalID: goalID, domainID: goal.domainIDs.first) }
            }
        }.keyboardDone().navigationTitle(store.t("goal.detail"))
            .confirmationDialog(store.t("delete.confirm"), isPresented: $delete) {
                Button(store.t("delete"), role: .destructive) { if store.change({ $0.deleteGoal(goalID) }) { dismiss() } }
            }
    }
}
struct GoalEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: GoalRecord
    init(goal: GoalRecord? = nil, domainID: String? = nil) {
        _draft = State(initialValue: goal ?? .init(domainIDs: [domainID ?? "learning"], end: Calendar.current.date(byAdding: .year, value: 1, to: Date())!))
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("title"), text: $draft.title).autocorrectionDisabled().accessibilityIdentifier("goal.title")
                Section(store.t("eight.areas")) {
                    ForEach(store.data.domains) { area in
                        Toggle(store.title(area.id), isOn: Binding(get: { draft.domainIDs.contains(area.id) }, set: { if $0 { if !draft.domainIDs.contains(area.id) { draft.domainIDs.append(area.id) } } else { draft.domainIDs.removeAll { $0 == area.id } } }))
                    }
                }
                Picker(store.t("parent.goal"), selection: $draft.parentID) {
                    Text(store.t("none")).tag(String?.none)
                    ForEach(store.data.goals.filter { $0.id != draft.id }) { Text($0.title).tag(Optional($0.id)) }
                }
                Picker(store.t("horizon"), selection: $draft.horizon) {
                    ForEach(["vision", "year", "quarter", "month", "week", "day"], id: \.self) { Text(store.t($0)).tag($0) }
                }
                ValueInput(title: "target", value: $draft.target)
                UnitPicker(unit: $draft.unit)
                DatePicker(store.t("start.date"), selection: $draft.start, displayedComponents: .date)
                DatePicker(store.t("end.date"), selection: $draft.end, displayedComponents: .date)
                Picker(store.t("priority"), selection: $draft.priority) { ForEach(0..<3) { Text(store.t("priority.\($0)")).tag($0) } }
                TextEditor(text: $draft.notes).frame(minHeight: 80).accessibilityLabel(store.t("notes"))
            }.keyboardDone().navigationTitle(store.t("goal.edit"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(store.t("save")) {
                            if store.change({ data in if let i = data.goals.firstIndex(where: { $0.id == draft.id }) { data.goals[i] = draft } else { data.goals.append(draft) } }) { dismiss() }
                        }.disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.domainIDs.isEmpty || draft.target <= 0 || draft.end < draft.start).accessibilityIdentifier("goal.save")
                    }
                }
        }
    }
}
struct TaskListScreen: View {
    @Environment(AppStore.self) private var store
    @State private var editor = false
    @State private var editing: PlannedTaskRecord?
    var body: some View {
        List {
            if store.data.tasks.isEmpty { EmptyState(key: "empty.tasks") }
            ForEach(store.data.tasks.filter { !$0.archived }) { task in
                Button { editing = task } label: {
                    VStack(alignment: .leading) {
                        Text(store.taskTitle(task.title)).foregroundStyle(.primary)
                        Text(store.t(task.recurrence)).font(.caption).foregroundStyle(.secondary)
                        if task.isHabit { Text(store.t("streak") + ": \(store.engine.streak(taskID: task.id, data: store.data, through: Date()))").font(.caption) }
                    }
                }.swipeActions { Button(store.t("archive")) { store.change { $0.archiveTask(task.id) } } }
            }
        }.keyboardDone().navigationTitle(store.t("tasks.habits"))
            .toolbar { Button { editor = true } label: { Image(systemName: "plus") } }
            .sheet(isPresented: $editor) { TaskEditor() }
            .sheet(item: $editing) { TaskEditor(task: $0) }
    }
}
struct TaskEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: PlannedTaskRecord
    @State private var hasEnd = false
    init(task: PlannedTaskRecord? = nil, goalID: String? = nil, domainID: String? = nil) {
        _draft = State(initialValue: task ?? .init(domainID: domainID ?? "learning", goalID: goalID))
        _hasEnd = State(initialValue: task?.end != nil)
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("title"), text: Binding(get: { store.taskTitle(draft.title) }, set: { draft.title = $0 })).autocorrectionDisabled().accessibilityIdentifier("task.title")
                Picker(store.t("area"), selection: $draft.domainID) { ForEach(store.data.domains) { Text(store.title($0.id)).tag($0.id) } }
                Picker(store.t("linked.goal"), selection: $draft.goalID) {
                    Text(store.t("none")).tag(String?.none)
                    ForEach(store.data.goals.filter { !$0.archived }) { Text($0.title).tag(Optional($0.id)) }
                }.accessibilityIdentifier("task.goal")
                ValueInput(title: "target", value: $draft.target)
                UnitPicker(unit: $draft.unit)
                DatePicker(store.t("start.date"), selection: $draft.start, displayedComponents: .date)
                Toggle(store.t("end.enabled"), isOn: $hasEnd)
                if hasEnd { DatePicker(store.t("end.date"), selection: Binding(get: { draft.end ?? draft.start }, set: { draft.end = $0 }), displayedComponents: .date) }
                Picker(store.t("recurrence"), selection: $draft.recurrence) { ForEach(Recurrence.allCases, id: \.rawValue) { Text(store.t($0.rawValue)).tag($0.rawValue) } }
                if draft.recurrence == "daily" || draft.recurrence == "weekly" {
                    ForEach(1...7, id: \.self) { day in
                        Toggle(store.engine.calendar.weekdaySymbols[day - 1], isOn: Binding(get: { draft.weekdays.contains(day) }, set: { if $0 { draft.weekdays.append(day) } else { draft.weekdays.removeAll { $0 == day } } }))
                    }
                }
                Toggle(store.t("habit"), isOn: $draft.isHabit)
                Picker(store.t("priority"), selection: $draft.priority) { ForEach(0..<3) { Text(store.t("priority.\($0)")).tag($0) } }
                TextEditor(text: $draft.notes).frame(minHeight: 80).accessibilityLabel(store.t("notes"))
                Text(store.t("task.edit.explanation")).font(.footnote)
            }.keyboardDone().navigationTitle(store.t("task.edit"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        if !hasEnd { draft.end = nil } else if draft.end == nil { draft.end = draft.start }
                        store.saveTask(draft)
                        if store.data.tasks.contains(where: { $0.id == draft.id }) && store.errorMessage == nil { dismiss() }
                    }.disabled(draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.target <= 0).accessibilityIdentifier("task.save") }
                }
        }
    }
}
