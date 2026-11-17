import SwiftUI

struct TemplateWeekPreview: View {
    @Environment(AppStore.self) private var store
    let selected: Set<String>
    private var days: [TemplateDayPreview] { store.engine.starterPreview(selected,from:Date(),in:store.data) }
    var body: some View {
        List {
            Text(store.t("template.preview.help"))
            Text("\(days.reduce(0) { $0+$1.items.count }) "+store.t("template.preview.entries"))
            ForEach(days) { day in
                Section(day.day) {
                    if day.items.isEmpty { Text(store.t("template.preview.empty")) }
                    ForEach(day.items) { item in
                        VStack(alignment:.leading) {
                            Text(store.t(item.id))
                            Text(item.target.formatted(.number.locale(store.locale))+" "+store.t(item.unit))
                        }
                    }
                }
            }
        }.navigationTitle(store.t("template.preview"))
    }
}
struct GuidedTemplateScreen: View {
    @Environment(AppStore.self) private var store
    let domainID: String
    @State private var start=Date()
    @State private var confirm=false
    @State private var goal=""
    @State private var task=""
    @State private var milestone=""
    private var template: GuidedTemplate { GuidedTemplate.choices.first { $0.id == domainID }! }
    private var applied: Bool { store.data.goals.contains { $0.id == "guided:"+domainID } || store.data.tasks.contains { $0.id == "guided:"+domainID+":task" } }
    var body: some View {
        Form {
            Text(store.t("example.help"))
            Section(store.t("goal.new")) {
                TextField(store.t("title"),text:$goal)
                DatePicker(store.t("start"),selection:$start,in:Date()...,displayedComponents:.date)
                Text(store.t("example.horizon"))
            }
            Section(store.t("milestones")) { TextField(store.t("title"),text:$milestone);Text(store.t("example.milestone.help")).font(.footnote) }
            Section(store.t("example.support")) {
                TextField(store.t("title"),text:$task)
                Text(template.minutes.formatted(.number.locale(store.locale))+" "+store.t("minutes"))
                Text(template.weekdays.map { store.engine.calendar.weekdaySymbols[$0-1] }.joined(separator:", "))
                Text(store.t("example.support.help")).font(.footnote)
                NavigationLink(destination:CapacityScreen()) { Text(store.t("capacity.title")) }
            }
            if applied {
                Text(store.t("example.applied")).accessibilityIdentifier("example.applied")
                NavigationLink(destination:GoalListScreen()) { Text(store.t("goals")) }
                NavigationLink(destination:WeeklyPlanScreen()) { Text(store.t("weekly.plan")) }
            } else {
                Button(store.t("example.apply")) { confirm=true }.disabled(goal.isEmpty || task.isEmpty || milestone.isEmpty).accessibilityIdentifier("example.apply")
            }
        }.keyboardDone().navigationTitle(store.t("example.navtitle"))
            .onAppear { if goal.isEmpty { goal=store.t(template.titleKey);task=store.t(template.taskKey);milestone=store.t("example.milestone") } }
            .confirmationDialog(store.t("example.confirm"),isPresented:$confirm) {
                Button(store.t("example.apply")) {
                    let engine=store.engine
                    store.change { try $0.applyGuidedTemplate(template,from:start,goalTitle:goal,taskTitle:task,milestoneTitle:milestone,engine:engine) }
                }.accessibilityIdentifier("example.confirm")
            }
    }
}
