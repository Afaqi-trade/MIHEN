import SwiftUI

struct GoalPlanningScreen: View {
    @Environment(AppStore.self) private var store
    let goalID: String
    @State private var start = Date()
    @State private var end = Date()
    @State private var weekdays = Set(1...7)
    @State private var confirmation = false
    @State private var milestone = ""
    private var goal: GoalRecord? { store.data.goals.first { $0.id == goalID } }
    private var proposal: [PlannedAllocation] {
        (try? store.engine.goalAllocations(goalID, in: store.data, from: start, through: end, weekdays: weekdays)) ?? []
    }
    private var problem: String? {
        do { _ = try store.engine.goalAllocations(goalID, in: store.data, from: start, through: end, weekdays: weekdays); return nil }
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
                        ForEach(1...7, id: \.self) { day in
                            Toggle(store.engine.calendar.weekdaySymbols[day - 1], isOn: Binding(get: { weekdays.contains(day) }, set: { if $0 { weekdays.insert(day) } else { weekdays.remove(day) } }))
                        }
                    }
                }
                Section(store.t("planning.preview")) {
                    if let problem { Text(store.t(problem)).foregroundStyle(.secondary) }
                    else {
                        Text("\(proposal.count) " + store.t("planning.actions"))
                        Text(store.t("planning.total") + ": " + proposal.reduce(0) { $0 + $1.amount }.formatted(.number.locale(store.locale)) + " " + store.t(goal.unit)).accessibilityIdentifier("goal.split.suggestion")
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
            .confirmationDialog(store.t("goal.split.confirm"), isPresented: $confirmation) {
                Button(store.t("goal.split.apply")) {
                    let engine = store.engine
                    store.change { document in
                        try engine.applyGoalPlan(goalID, from: start, through: end, weekdays: weekdays, in: &document)
                        let title = milestone.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !title.isEmpty { document.milestones.append(.init(goalID: goalID, title: title, due: min(end, engine.addingDays(89, to: start)))) }
                    }
                }
            }
    }
}
