import SwiftUI

struct GoalPlanningScreen: View {
    @Environment(AppStore.self) private var store
    let goalID: String
    @State private var start = Date()
    @State private var end = Date()
    @State private var weekdays = Set(1...7)
    @State private var confirmation = false
    @State private var milestone = ""
    @State private var createMilestones = false
    @State private var byCapacity = false
    @State private var minutesPerUnit = 1.0
    @State private var supporting = false
    @State private var oldTasks=Set<String>()
    private func calculate() throws -> [PlannedAllocation] {
        guard let goal else { return [] }
        if byCapacity {
            guard !store.data.tasks.contains(where: { $0.goalID == goalID && !$0.archived }) else { throw PlanError.invalid("planning.linked") }
            return try store.engine.capacityAllocations(total:max(0,goal.target-store.engine.goalValue(goalID,in:store.data)),unit:goal.unit,minutesPerUnit:goal.unit == "minutes" ? 1 : minutesPerUnit,from:start,through:end,weekdays:weekdays,in:store.data)
        }
        return try store.engine.goalAllocations(goalID,in:store.data,from:start,through:end,weekdays:weekdays)
    }
    private var goal: GoalRecord? { store.data.goals.first { $0.id == goalID } }
    private var proposal: [PlannedAllocation] {
        (try? calculate()) ?? []
    }
    private var problem: String? {
        do { _ = try calculate(); return nil }
        catch { return (error as? PlanError)?.errorDescription ?? "planning.invalid" }
    }
    var body: some View {
        Form {
            if let goal {
                Section(store.t("planning.intention")) {
                    Text(goal.title).font(.headline)
                    Text(store.t("planning.noConversion")).font(.footnote)
                    TextField(store.t("planning.milestone.placeholder"), text: $milestone).accessibilityIdentifier("goal.split.milestone")
                    Text(store.t("planning.next90")).font(.caption).foregroundStyle(.secondary)
                }
                Section(store.t("date")) {
                    DatePicker(store.t("start.date"), selection: $start, in: store.engine.calendar.startOfDay(for: Date())..., displayedComponents: .date)
                    DatePicker(store.t("end.date"), selection: $end, displayedComponents: .date)
                    DisclosureGroup(store.t("planning.availableDays")) {
                        WeekdayPresets(weekdays: $weekdays)
                        ForEach(1...7, id: \.self) { day in
                            Toggle(store.engine.calendar.weekdaySymbols[day - 1], isOn: Binding(get: { weekdays.contains(day) }, set: { if $0 { weekdays.insert(day) } else { weekdays.remove(day) } }))
                        }
                    }
                }
                Section(store.t("planning.firstWeek")) {
                    Text(store.t("planning.firstWeek.help")).font(.footnote).foregroundStyle(.secondary)
                    if let problem { Text(store.t(problem)).foregroundStyle(.secondary) }
                    else {
                        let first = store.engine.firstPlanningWeek(proposal, from: start)
                        if first.isEmpty { Text(store.t("planning.firstWeek.empty")) }
                        else {
                            ForEach(first, id: \.day) { item in
                                HStack {
                                    Text(store.engine.date(item.day) ?? start, format: .dateTime.weekday(.abbreviated).day().month())
                                    Spacer()
                                    Text(item.amount.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit))
                                }
                            }
                            Text(store.t("planning.firstWeek.total") + ": " + first.reduce(0.0) { $0 + $1.amount }.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)).font(.footnote).accessibilityIdentifier("goal.firstWeek.total")
                        }
                    }
                }.accessibilityIdentifier("goal.firstWeek")
                Section(store.t("capacity.title")) {
                    Toggle(store.t("capacity.use"),isOn:$byCapacity)
                    NavigationLink(destination:CapacityScreen()) { Text(store.t("capacity.title")) }
                    if byCapacity && goal.unit != "minutes" { ValueInput(title:"capacity.perUnit",value:$minutesPerUnit) }
                    if byCapacity { Text(store.t("capacity.future.confirm")).font(.footnote) }
                    Button(store.t("capacity.extend")) { end=store.engine.addingDays(30,to:end) }
                    NavigationLink(destination:GoalEditor(goal:goal)) { Text(store.t("capacity.editGoal")) }
                }
                Section(store.t("planning.support")) {
                    Text(store.t("planning.support.help")).font(.footnote)
                    Button(store.t("planning.support")) { oldTasks=Set(store.data.tasks.map(\.id));supporting=true }
                }
                Section(store.t("planning.roadmap")) {
                    let first90 = proposal.filter { item in
                        guard let day = store.engine.date(item.day) else { return false }
                        return day < store.engine.addingDays(90, to: store.engine.calendar.startOfDay(for: start))
                    }.reduce(0.0) { $0 + $1.amount }
                    Text(store.t("planning.next90") + ": " + first90.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit))
                    DisclosureGroup(store.t("planning.months")) {
                        ForEach(store.engine.planningStages(proposal, component: .month)) { stage in stageRow(stage, unit: goal.unit) }
                    }
                    DisclosureGroup(store.t("planning.weeks")) {
                        ForEach(store.engine.planningStages(proposal, component: .weekOfYear)) { stage in stageRow(stage, unit: goal.unit) }
                    }
                    Toggle(store.t("planning.saveMilestones"), isOn: $createMilestones)
                    Text(store.t("planning.milestones.help")).font(.footnote)
                }
                Section(store.t("planning.preview")) {
                    if let problem { Text(store.t(problem)).foregroundStyle(.secondary) }
                    else {
                        Text("\(proposal.count) " + store.t("planning.actions"))
                        let total = proposal.reduce(0.0) { $0 + $1.amount }
                        Text(store.t("planning.total") + ": " + total.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)).accessibilityIdentifier("goal.split.suggestion")
                        if let low = proposal.map(\.amount).min(), let high = proposal.map(\.amount).max() {
                            Text(store.t("planning.range") + ": " + low.formatted(.number.locale(store.locale)) + " - " + high.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit))
                        }
                        DisclosureGroup(store.t("planning.preview")) {
                            ForEach(Array(proposal.enumerated()), id: \.offset) { _, item in
                                HStack { Text(store.engine.date(item.day) ?? start, format: .dateTime.day().month().year()); Spacer(); Text(item.amount.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)) }
                            }
                        }
                    }
                    Button(store.t("goal.split.apply")) { confirmation = true }.buttonStyle(.borderedProminent)
                        .disabled(proposal.isEmpty).accessibilityIdentifier("goal.split.apply")
                }
            }
        }.keyboardDone().navigationTitle(store.t("goal.split"))
            .onAppear {
                if let goal {
                    start = max(store.engine.calendar.startOfDay(for: Date()), store.engine.calendar.startOfDay(for: goal.start))
                    end = min(goal.end, store.engine.addingDays(365, to: start))
                }
            }
            .sheet(isPresented:$supporting,onDismiss:{
                let new=store.data.tasks.filter { !oldTasks.contains($0.id) }
                store.change { data in for task in new { data.goalSupports.append(.init(goalID:goalID,taskID:task.id)) } }
            }) { TaskEditor(task:.init(title:goal?.title ?? "",domainID:goal?.domainIDs.first ?? "learning",recurrence:"daily",target:20,unit:"minutes",isHabit:true)) }
            .confirmationDialog(store.t("goal.split.confirm"), isPresented: $confirmation) {
                Button(store.t("goal.split.apply")) {
                    let engine = store.engine
                    store.change { document in
                        if byCapacity {
                            try engine.applyCapacityGoalPlan(goalID,from:start,through:end,weekdays:weekdays,minutesPerUnit:goal?.unit == "minutes" ? 1 : minutesPerUnit,in:&document)
                        } else { try engine.applyGoalPlan(goalID, from: start, through: end, weekdays: weekdays, in: &document) }
                        if createMilestones, let goal {
                            for stage in engine.planningStages(proposal, component: .month) {
                                let formatter = DateFormatter(); formatter.locale = store.locale; formatter.timeZone = engine.timeZone; formatter.dateFormat = "LLLL yyyy"
                                let title = formatter.string(from: stage.start) + " · " + stage.total.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)
                                document.milestones.append(.init(goalID: goalID, title: title, due: min(stage.end, end)))
                            }
                        }
                        let title = milestone.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !title.isEmpty { document.milestones.append(.init(goalID: goalID, title: title, due: min(end, engine.addingDays(89, to: start)))) }
                    }
                }
            }
    }
    private func stageRow(_ stage: PlanningStage, unit: String) -> some View {
        VStack(alignment: .leading) {
            Text(stage.start, format: .dateTime.day().month()); Text(stage.end, format: .dateTime.day().month())
            Text(stage.total.formatted(.number.locale(store.locale)) + " " + store.t(unit) + " · \(stage.actions) " + store.t("planning.actions")).font(.subheadline)
        }
    }

}
