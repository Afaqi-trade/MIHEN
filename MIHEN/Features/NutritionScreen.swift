import SwiftUI

struct NutritionScreen: View {
    @Environment(AppStore.self) private var store
    @State private var date = Date()
    @State private var kind = "food"
    @State private var amount = 0.0
    @State private var note = ""
    @State private var meal = "other"
    @State private var foodName = ""
    @State private var lastAdded: String?
    @State private var editing: DomainActivityRecord?
    @State private var plan: NutritionPlanRecord?
    private var rows: [DomainActivityRecord] {
        store.data.activities.filter { ["food", "energyBurned", "water"].contains($0.kind) && store.engine.key($0.date) == store.engine.key(date) }
    }
    private var recent: [DomainActivityRecord] {
        let used=Dictionary(uniqueKeysWithValues:store.data.activityAnnotations.map { ($0.activityID,$0.lastUsed) })
        return Array(store.data.activities.filter { ["food","energyBurned","water"].contains($0.kind) && !$0.id.hasPrefix("health.") }.sorted { (used[$0.id] ?? $0.date) > (used[$1.id] ?? $1.date) }.prefix(5))
    }
    private func total(_ kind: String) -> Double { store.data.nutritionTotal(kind,on:date,engine:store.engine) }
    private var usesHealth: Bool { rows.contains { $0.id.hasPrefix("health.energy:") } }
    var body: some View {
        Form {
            NavigationLink(destination: HealthSummaryScreen()) { Text(store.t("health.connection")) }
            DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
            Section(store.t("nutrition.summary")) {
                Text(store.t("activity.food") + ": " + total("food").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.energyBurned") + ": " + total("energyBurned").formatted(.number.locale(store.locale)) + " kcal")
                Text(store.t("activity.water") + ": " + total("water").formatted(.number.locale(store.locale)) + " ml")
                Text(store.t(usesHealth ? "health.source" : "manual.source")).font(.caption)
                Text(store.t("nutrition.summary.limit")).font(.footnote).foregroundStyle(.secondary)
                DisclosureGroup(store.t("report.formula")) { Text(store.t("nutrition.explanation")).font(.footnote) }
            }
            Section(store.t("nutrition.quick")) {
                ViewThatFits(in:.horizontal) {
                    HStack { quickButtons }
                    VStack(alignment:.leading) { quickButtons }
                }.buttonStyle(.borderless)
                NavigationLink(destination:WaterShortcutScreen()) { Text(store.t("nutrition.shortcuts")) }
                if let lastAdded { Button(store.t("undo")) { if store.change({ $0.activities.removeAll { $0.id == lastAdded } }) { self.lastAdded = nil } } }
            }
            Section(store.t("nutrition.plan")) {
                Button(store.t("nutrition.plan.add")) { plan = .init(date:date) }.accessibilityIdentifier("nutrition.plan.add")
                ForEach(["food","water","energyBurned"],id:\.self) { key in
                    let planned=store.data.nutritionTotal(key,on:date,engine:store.engine,planned:true)
                    if planned > 0 {
                        VStack(alignment:.leading) {
                            Text(store.t("activity."+key))
                            Text(plannedLine(key,planned:planned))
                        }
                    }
                }
                ForEach(store.data.nutritionPlans.filter { store.engine.key($0.date) == store.engine.key(date) }) { row in
                    Button { plan=row } label: {
                        Text([store.t("meal."+row.meal),row.title,row.amount.formatted(.number.locale(store.locale))+" "+row.unit].filter { !$0.isEmpty }.joined(separator:" · "))
                    }.swipeActions { Button(store.t("delete"),role:.destructive) { store.change { $0.nutritionPlans.removeAll { $0.id == row.id } } } }
                }
                Text(store.t("nutrition.plan.help")).font(.footnote)
            }
            DisclosureGroup(store.t("nutrition.recent")) {
                ForEach(recent) { row in
                    Button {
                        let annotation=store.data.activityAnnotations.first { $0.activityID == row.id }
                        kind=row.kind;amount=row.amount;note=row.note;meal=annotation?.meal ?? "other";foodName=annotation?.title ?? ""
                    } label: { Text(recentLabel(row)) }
                }
                Text(store.t("nutrition.recent.help")).font(.footnote)
            }
            Section(store.t("activity.new")) {
                Picker(store.t("type"), selection: $kind) { ForEach(["food", "energyBurned", "water"], id: \.self) { Text(store.t("activity." + $0)).tag($0) } }
                if kind == "food" { MealPicker(meal:$meal);TextField(store.t("nutrition.name"),text:$foodName).accessibilityIdentifier("nutrition.name") }
                ValueInput(title: "amount", value: $amount)
                Text(store.t(kind == "water" ? "nutrition.amount.water" : "nutrition.amount.energy")).font(.caption)
                if kind == "energyBurned" && usesHealth { Text(store.t("health.source.help")).font(.footnote) }
                TextField(store.t("notes"), text: $note)
                Button(store.t("save")) {
                    let engine=store.engine
                    if store.change({ try $0.saveNutrition(date:date,kind:kind,amount:amount,meal:meal,title:foodName,note:note,engine:engine) }) { amount=0;note="";foodName="" }
                }.disabled(!amount.isFinite || amount <= 0 || (kind == "energyBurned" && usesHealth)).accessibilityIdentifier("nutrition.save")
            }
            Section(store.t("history")) {
                ForEach(rows.sorted { $0.date > $1.date }) { row in
                    VStack(alignment: .leading) {
                        Text(store.t("activity." + row.kind))
                        if let annotation=store.data.activityAnnotations.first(where: { $0.activityID == row.id }) { Text(store.t("meal."+annotation.meal)+" · "+annotation.title) }
                        Text(store.t(row.id.hasPrefix("health.") ? "health.source" : "manual.source")).font(.caption)
                        Text(row.amount.formatted(.number.locale(store.locale)) + " " + row.unit)
                        Text(row.note)
                        if !row.id.hasPrefix("health.") { Button(store.t("edit")) { editing=row }.accessibilityIdentifier("nutrition.edit."+row.id) }
                    }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.activities.removeAll { $0.id == row.id } } } }
                }
            }
        }.buttonStyle(.borderless).keyboardDone().navigationTitle(store.t("nutrition"))
            .sheet(item:$editing) { NutritionEntryEditor(record:$0) }
            .sheet(item:$plan) { NutritionPlanEditor(record:$0) }
    }
    private func plannedLine(_ kind: String, planned: Double) -> String {
        let plannedText=planned.formatted(.number.locale(store.locale))
        let actualText=total(kind).formatted(.number.locale(store.locale))
        let unit=kind == "water" ? "ml" : "kcal"
        return store.t("nutrition.planned")+": "+plannedText+" · "+store.t("nutrition.actual")+": "+actualText+" "+unit
    }
    private func recentLabel(_ row: DomainActivityRecord) -> String {
        let name=store.data.activityAnnotations.first { $0.activityID == row.id }?.title ?? ""
        let title=name.isEmpty ? store.t("activity."+row.kind) : name
        return title+" · "+row.amount.formatted(.number.locale(store.locale))+" "+row.unit
    }
    @ViewBuilder private var quickButtons: some View {
        ForEach(store.data.waterShortcuts,id:\.self) { value in Button("+\(value) ml") { addWater(value) }.frame(minHeight:44) }
    }
    private func addWater(_ value: Int) {
        let engine=store.engine
        var id: String?
        if store.change({ id=try $0.saveNutrition(date:date,kind:"water",amount:Double(value),meal:"other",title:"",note:"",engine:engine) }) { lastAdded=id }
    }
}
struct MealPicker: View {
    @Environment(AppStore.self) private var store
    @Binding var meal: String
    var body: some View { Picker(store.t("nutrition.meal"),selection:$meal) { ForEach(["breakfast","lunch","dinner","snack","other"],id:\.self) { Text(store.t("meal."+$0)).tag($0) } } }
}
struct WaterShortcutScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var values=""
    var body: some View {
        Form {
            Text(store.t("nutrition.shortcuts.help"))
            SelectAllTextField(title:"250,500",text:$values).accessibilityLabel(store.t("nutrition.shortcuts")).accessibilityIdentifier("nutrition.shortcuts")
            Button(store.t("save")) { if store.change({ $0.setOption("water.quick",value:values) }) { dismiss() } }.accessibilityIdentifier("nutrition.shortcuts.save")
        }.navigationTitle(store.t("nutrition.shortcuts")).onAppear { values=store.data.option("water.quick",fallback:"250,500") }
    }
}
struct NutritionEntryEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State var record: DomainActivityRecord
    @State private var meal="other"
    @State private var name=""
    private var linked: Bool { store.data.sourceLinks.contains { $0.sourceKind == "activity" && $0.sourceID == record.id } }
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(store.t("date"),selection:$record.date,displayedComponents:.date).disabled(linked)
                if linked { Text(store.t("source.disconnectFirst")).font(.footnote) }
                Text(store.t("activity."+record.kind))
                if record.kind == "food" { MealPicker(meal:$meal);TextField(store.t("nutrition.name"),text:$name) }
                ValueInput(title:"amount",value:$record.amount,fieldID:"nutrition.edit.amount")
                TextField(store.t("notes"),text:$record.note)
            }.keyboardDone().navigationTitle(store.t("edit"))
                .toolbar {
                    ToolbarItem(placement:.cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement:.confirmationAction) { Button(store.t("save")) {
                        let engine=store.engine
                        if store.change({ try $0.saveNutrition(id:record.id,date:record.date,kind:record.kind,amount:record.amount,meal:meal,title:name,note:record.note,engine:engine) }) { dismiss() }
                    }.disabled(record.amount <= 0 || !record.amount.isFinite) }
                }.onAppear { if let row=store.data.activityAnnotations.first(where: { $0.activityID == record.id }) { meal=row.meal;name=row.title } }
        }
    }
}
struct NutritionPlanEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State var record: NutritionPlanRecord
    var body: some View {
        NavigationStack {
            Form {
                Text(store.t("nutrition.plan.help"))
                DatePicker(store.t("date"),selection:$record.date,displayedComponents:.date)
                Picker(store.t("type"),selection:$record.kind) { ForEach(["food","water","energyBurned"],id:\.self) { Text(store.t("activity."+$0)).tag($0) } }
                MealPicker(meal:$record.meal)
                TextField(store.t("nutrition.name"),text:$record.title)
                ValueInput(title:"amount",value:$record.amount,fieldID:"nutrition.plan.amount")
                Text(record.kind == "water" ? "ml" : "kcal")
            }.keyboardDone().navigationTitle(store.t("nutrition.plan"))
                .toolbar {
                    ToolbarItem(placement:.cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement:.confirmationAction) { Button(store.t("save")) {
                        record.unit=record.kind == "water" ? "ml" : "kcal"
                        if store.change({ try $0.saveNutritionPlan(record) }) { dismiss() }
                    }.disabled(record.amount <= 0 || !record.amount.isFinite).accessibilityIdentifier("nutrition.plan.save") }
                }
        }
    }
}
