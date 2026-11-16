import SwiftUI

struct CapacityScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var minutes=Array(repeating:0,count:7)
    var body: some View {
        Form {
            Text(store.t("capacity.help"))
            ForEach(1...7,id:\.self) { day in
                IntegerInput(title:store.engine.calendar.weekdaySymbols[day-1],value:$minutes[day-1],fieldID:"capacity.day.\(day)")
            }
            Text(store.t("capacity.minutes")).font(.footnote)
            Button(store.t("save")) {
                if store.change({ data in data.capacities=(1...7).map { .init(weekday:$0,minutes:minutes[$0-1]) } }) { dismiss() }
            }.disabled(minutes.contains { !(0...1440).contains($0) }).accessibilityIdentifier("capacity.save")
        }.keyboardDone().navigationTitle(store.t("capacity.title"))
            .onAppear { for row in store.data.capacities { minutes[row.weekday-1]=row.minutes } }
    }
}
struct WeeklyFocusEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let week: Date
    @State private var chosen=[String]()
    var body: some View {
        List {
            Text(store.t("focus.explanation"))
            Text("\(chosen.count) / 3")
            Section(store.t("goals")) {
                ForEach(store.data.goals.filter { !$0.archived }) { goal in choice("goal:"+goal.id,title:goal.title) }
            }
            Section(store.t("tasks.habits")) {
                ForEach(store.data.tasks.filter { !$0.archived }) { task in choice("task:"+task.id,title:store.taskTitle(task.title)) }
            }
        }.navigationTitle(store.t("week.focus.select"))
            .toolbar { Button(store.t("save")) {
                let engine=store.engine
                if store.change({ data in
                    try data.setWeeklyFocus(week:week,items:chosen.map { key in let pieces=key.split(separator:":",maxSplits:1);return (String(pieces[0]),String(pieces[1])) },engine:engine)
                }) { dismiss() }
            }.accessibilityIdentifier("weekly.focus.save") }
            .onAppear {
                let key=store.engine.key(store.engine.calendar.dateInterval(of:.weekOfYear,for:week)!.start)
                chosen=store.data.weeklyFocuses.filter { $0.week == key }.sorted { $0.rank < $1.rank }.map { $0.kind+":"+$0.referenceID }
            }
    }
    private func choice(_ key: String, title: String) -> some View {
        Toggle(title,isOn:Binding(get:{ chosen.contains(key) },set:{ value in
            if value && chosen.count < 3 { chosen.append(key) } else if !value { chosen.removeAll { $0 == key } }
        })).disabled(!chosen.contains(key) && chosen.count >= 3)
    }
}
struct DayCapacityScreen: View {
    @Environment(AppStore.self) private var store
    let day: Date
    var body: some View {
        List {
            ForEach(store.occurrences(on:day).filter { !["cancelled","moved","skipped"].contains($0.status) }) { row in
                if let task=store.data.tasks.first(where: { $0.id == row.taskID }) {
                    NavigationLink(destination:TaskEditor(task:task)) {
                        VStack(alignment:.leading) { Text(store.taskTitle(row.title));Text(store.t("capacity.estimate.help")).font(.caption) }
                    }
                }
            }
        }.navigationTitle(store.t("capacity.estimate"))
    }
}
