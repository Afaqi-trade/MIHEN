import SwiftUI

struct GoalPlanningScreen: View {
    @Environment(AppStore.self) private var store
    let goalID: String
    @State private var start = Date()
    @State private var end = Date()
    @State private var weekdays = Set(1...7)
    @State private var confirmation = false
    private var goal: GoalRecord? { store.data.goals.first { $0.id == goalID } }
    private var dates: [Date] {
        guard end >= start, store.engine.calendar.dateComponents([.day], from: start, to: end).day ?? 0 <= 366 else { return [] }
        return store.engine.days(from: start, through: end).filter { weekdays.contains(store.engine.calendar.component(.weekday, from: $0)) }
    }
    private var remaining: Double { guard let goal else { return 0 }; return max(0, goal.target - store.engine.goalValue(goalID, in: store.data)) }
    var body: some View {
        Form {
            if let goal {
                Text(goal.title).font(.headline)
                Text(store.t("goal.split.explanation"))
                DatePicker(store.t("start.date"), selection: $start, displayedComponents: .date)
                DatePicker(store.t("end.date"), selection: $end, displayedComponents: .date)
                ForEach(1...7, id: \.self) { day in
                    Toggle(store.engine.calendar.weekdaySymbols[day - 1], isOn: Binding(get: { weekdays.contains(day) }, set: { if $0 { weekdays.insert(day) } else { weekdays.remove(day) } }))
                }
                Text("\(dates.count) " + store.t("days"))
                if !dates.isEmpty {
                    Text(store.t("daily.suggestion") + ": " + (remaining / Double(dates.count)).formatted(.number.precision(.fractionLength(0...2)).locale(store.locale)) + " " + store.t(goal.unit)).accessibilityIdentifier("goal.split.suggestion")
                }
                Button(store.t("goal.split.apply")) { confirmation = true }
                    .disabled(dates.isEmpty || remaining <= 0 || store.data.tasks.contains { $0.goalID == goalID && !$0.archived })
            }
        }.navigationTitle(store.t("goal.split"))
            .onAppear { if let goal { start = max(Date(), goal.start); end = goal.end } }
            .confirmationDialog(store.t("goal.split.confirm"), isPresented: $confirmation) {
                Button(store.t("goal.split.apply")) {
                    guard let goal, !dates.isEmpty else { return }
                    let selectedDates = dates
                    let target = remaining / Double(selectedDates.count)
                    let engine = store.engine
                    store.change { document in
                        for day in selectedDates {
                            document.tasks.append(.init(title: goal.title, domainID: goal.domainIDs.first ?? "learning", goalID: goalID, start: day, end: day, target: target, unit: goal.unit, priority: goal.priority))
                        }
                        engine.materialize(&document, from: start, through: end)
                    }
                }
            }
    }
}
