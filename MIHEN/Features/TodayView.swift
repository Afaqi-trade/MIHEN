import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dynamicTypeSize) private var textSize
    @State private var taskEditor = false
    @State private var noteEditor = false
    @State private var focusEditor = false
    @State private var completedOpen = false
    private var today: Date { Date() }
    private var rows: [TaskOccurrenceRecord] { store.occurrences(on: today) }
    private var pending: [TaskOccurrenceRecord] { rows.filter { ["planned", "partial"].contains($0.status) } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !textSize.isAccessibilitySize { Text(store.t("greeting.salaam")).font(.subheadline.weight(.medium)).foregroundStyle(Color.mihenGreen) }
                Text(today, format: .dateTime.weekday(.wide).day().month(.wide)).font(textSize.isAccessibilitySize ? .caption : .body).foregroundStyle(.secondary)
                if store.preferences.showHijri { Text(hijriDate).font(.subheadline).foregroundStyle(.secondary) }
                if !textSize.isAccessibilitySize { summaryCard }
                if store.lastProgressChange != nil { Button(store.t("undo")) { store.undoProgress() }.accessibilityIdentifier("today.undo") }
                if rows.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        if textSize.isAccessibilitySize {
                            Button(store.t("today.first.add")) { taskEditor = true }.buttonStyle(.borderedProminent)
                        }
                        Text(store.t("today.first.title")).font(.title2.bold())
                        Text(store.t("today.first.body"))
                        if !textSize.isAccessibilitySize {
                            Button(store.t("today.first.add")) { taskEditor = true }.buttonStyle(.borderedProminent)
                        }
                        NavigationLink(destination: StarterTemplatesScreen()) { Text(store.t("templates.choose")) }
                    }.mihenCard()
                } else {
                    (textSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout())) {
                        Text(store.t("today.plan")).font(.title2.bold())
                        if !textSize.isAccessibilitySize { Spacer() }
                        Button(store.t("focus.choose")) { focusEditor = true }.accessibilityIdentifier("today.focus")
                    }
                    ForEach(pending) { OccurrenceRow(occurrence: $0) }
                    let completed = rows.filter { $0.status == "completed" }
                    if !completed.isEmpty {
                        DisclosureGroup(isExpanded: $completedOpen) {
                            ForEach(completed) { OccurrenceRow(occurrence: $0) }
                        } label: { Text(store.t("completed") + " · \(completed.count)") }
                        .accessibilityIdentifier("today.completed")
                    }
                }
                if textSize.isAccessibilitySize && !rows.isEmpty { summaryCard }
                (textSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout())) {
                    NavigationLink(destination: WeeklyPlanScreen()) { Label(store.t("weekly.plan"), systemImage: "calendar") }
                    if !textSize.isAccessibilitySize { Spacer() }
                    Button { noteEditor = true } label: { Label(store.t("quick.note"), systemImage: "square.and.pencil") }
                }.font(.subheadline)
                if store.data.domains.contains(where: { $0.key == "spiritual" && $0.enabled }) {
                    NavigationLink(destination: SpiritualScreen()) { Label(store.t("spiritual"), systemImage: "sparkles").mihenCard() }
                }
                let dueReviews = store.data.memorization.filter { item in
                    store.engine.nextReview(item, reviews: store.data.memorizationReviews).map { $0 <= today } ?? false
                }
                if !dueReviews.isEmpty { NavigationLink(destination: MemorizationScreen()) { Text(store.t("today.reviewsDue") + ": \(dueReviews.count)") } }
                let events = store.engine.upcomingEvents(store.data.events, after: today)
                ForEach(Array(events.prefix(3)), id: \.event.id) { item in
                    VStack(alignment: .leading) { Text(item.event.title); Text(item.next, format: .dateTime.day().month().hour().minute()).font(.caption).foregroundStyle(.secondary) }.mihenCard()
                }
                NavigationLink(destination: JournalScreen()) { Text(store.t("reviews")) }
                NavigationLink(destination: TaskListScreen()) { Text(store.t("manage")) }.font(.footnote)
            }.padding()
        }.background(Color.mihenBackground).navigationTitle(textSize.isAccessibilitySize ? store.t("today") : greeting)
            .navigationBarTitleDisplayMode(textSize.isAccessibilitySize ? .inline : .large)
            .toolbar { Button { taskEditor = true } label: { Image(systemName: "plus").frame(minWidth: 44, minHeight: 44) }.accessibilityLabel(store.t("task.new")).accessibilityIdentifier("today.add") }
            .onAppear { completedOpen = pending.isEmpty }
            .onChange(of: pending.count) { _, count in if count == 0 { completedOpen = true } }
            .sheet(isPresented: $taskEditor) { TaskEditor() }
            .sheet(isPresented: $noteEditor) { JournalEditor(kind: "note") }
            .sheet(isPresented: $focusEditor) { TodayFocusScreen() }
    }
    private var greeting: String {
        let hour = store.engine.calendar.component(.hour, from: today)
        return store.t(hour < 5 || hour >= 22 ? "greeting.night" : hour < 12 ? "greeting.morning" : hour < 18 ? "greeting.day" : "greeting.evening") + (store.preferences.name.isEmpty ? "" : ", \(store.preferences.name)")
    }
    private var hijriDate: String {
        let formatter = DateFormatter(); formatter.calendar = store.engine.hijriCalendar
        formatter.locale = store.locale; formatter.timeZone = store.engine.timeZone; formatter.dateStyle = .long
        return formatter.string(from: store.engine.addingDays(store.preferences.hijriOffset, to: today))
    }
    private var summaryCard: some View {
        let summary = store.engine.summary(store.data, on: today)
        return VStack(alignment: .leading, spacing: 8) {
            HStack { Text(store.t("today.steps")).font(.system(.headline,design:.serif));Spacer();MihenMotif().stroke(.white.opacity(0.5),lineWidth:1).frame(width:32,height:32).accessibilityHidden(true) }
            Text("\(summary.completed) " + store.t("today.finished") + " · \(summary.partial) " + store.t("today.started"))
                .font(.title3.bold()).accessibilityIdentifier("today.effort")
            if summary.partial > 0 { Text(store.t("today.partial.encouragement")).font(.subheadline) }
            else if summary.completed > 0 { Text(store.t("today.completed.encouragement")).font(.subheadline) }
            else { Text(store.t("today.next.encouragement")).font(.subheadline) }
            if let ratio = summary.ratio {
                Text(store.t("completion.rate") + ": " + ratio.formatted(.percent.precision(.fractionLength(0)).locale(store.locale))).font(.caption).accessibilityIdentifier("today.progress")
            }
            let focus = pending.filter { $0.priority == 2 }
            if !focus.isEmpty { Text(store.t("top.three")).font(.subheadline.bold()); ForEach(Array(focus.prefix(3))) { Text("• " + store.taskTitle($0.title)).font(.subheadline) } }
        }.padding(20).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.white)
            .background(LinearGradient(colors:[Color.mihenNavy,Color(red:0.08,green:0.29,blue:0.30)],startPoint:.topLeading,endPoint:.bottomTrailing), in: RoundedRectangle(cornerRadius:24))
    }
}

struct TodayFocusScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selected = Set<String>()
    var body: some View {
        NavigationStack {
            List {
                Text(store.t("focus.explanation")).font(.footnote)
                Text("\(selected.count) / 3").font(.headline)
                ForEach(store.occurrences(on: Date()).filter { ["planned", "partial"].contains($0.status) }) { row in
                    Toggle(store.taskTitle(row.title), isOn: Binding(get: { selected.contains(row.id) }, set: { if $0 && selected.count < 3 { selected.insert(row.id) } else { selected.remove(row.id) } }))
                }
            }.navigationTitle(store.t("focus.choose"))
                .onAppear { selected = Set(store.occurrences(on: Date()).filter { $0.priority == 2 && ["planned", "partial"].contains($0.status) }.prefix(3).map(\.id)) }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        let today = store.engine.key(Date())
                        if store.change({ data in
                            for i in data.occurrences.indices where data.occurrences[i].day == today && ["planned", "partial"].contains(data.occurrences[i].status) {
                                if selected.contains(data.occurrences[i].id) { data.occurrences[i].priority = 2 }
                                else if data.occurrences[i].priority == 2 { data.occurrences[i].priority = 1 }
                            }
                        }) { dismiss() }
                    } }
                }
        }
    }
}
struct OccurrenceRow: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dynamicTypeSize) private var textSize
    let occurrence: TaskOccurrenceRecord
    @State private var details = false
    private var active: Bool { ["planned", "partial", "completed"].contains(occurrence.status) }
    var body: some View {
        (textSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout(spacing: 12))) {
            Button {
                store.progress(occurrence.id, value: occurrence.status == "completed" ? 0 : occurrence.target)
            } label: {
                Image(systemName: occurrence.status == "completed" ? "checkmark.circle.fill" : occurrence.status == "partial" ? "circle.lefthalf.filled" : "circle")
                    .font(.title2).foregroundStyle(occurrence.status == "completed" ? Color.mihenGreen : .secondary).frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!active).accessibilityLabel(store.t("complete") + " " + store.taskTitle(occurrence.title))
            .accessibilityIdentifier("occurrence.complete.\(occurrence.taskID)")
            Button { details = true } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(store.taskTitle(occurrence.title)).font(.headline).foregroundStyle(.primary)
                    Text("\(occurrence.value.formatted(.number.locale(store.locale))) / \(occurrence.target.formatted(.number.locale(store.locale))) \(store.t(occurrence.unit))").font(.subheadline).foregroundStyle(.secondary)
                    Text(store.t(occurrence.status)).font(.caption).foregroundStyle(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.buttonStyle(.plain)
            if occurrence.target > 1 && active {
                Button { store.progress(occurrence.id, value: max(0, occurrence.value - 1)) } label: { Image(systemName: "minus").frame(minWidth: 44, minHeight: 44) }
                    .accessibilityLabel(store.t("decrease"))
                Button { store.progress(occurrence.id, value: occurrence.value + 1) } label: { Image(systemName: "plus").frame(minWidth:44,minHeight:44) }
                    .accessibilityLabel(store.t("increase"))
            }
        }.buttonStyle(.borderless).mihenCard()
            .sheet(isPresented: $details) { OccurrenceDetail(id: occurrence.id) }
    }
}
struct OccurrenceDetail: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let id: String
    @State private var value = 0.0
    @State private var destination = Date()
    @State private var confirmMove = false
    @State private var distributionEnd = Date()
    @State private var proposal: [Allocation] = []
    @State private var confirmDistribution = false
    var body: some View {
        NavigationStack {
            Form {
                if let row = store.data.occurrences.first(where: { $0.id == id }) {
                    Section(store.taskTitle(row.title)) {
                        Text(row.day)
                        Text(store.title(row.domainID))
                        ValueInput(title: "progress.value", value: $value)
                        Button(store.t("save")) { store.progress(id, value: value); dismiss() }.disabled(!["planned", "partial", "completed"].contains(row.status))
                    }
                    Section {
                        NavigationLink(destination:SourceLinkScreen(occurrenceID:id)) { Text(store.t("source.title")) }.accessibilityIdentifier("source.openLink")
                    }
                    Section(store.t("reschedule")) {
                        DatePicker(store.t("date"), selection: $destination, displayedComponents: .date)
                        Text(store.t("reschedule.explanation")).font(.footnote)
                        Button(store.t("move")) { confirmMove = true }
                        DatePicker(store.t("redistribute.end"), selection: $distributionEnd, displayedComponents: .date)
                        Button(store.t("redistribute.preview")) {
                            do {
                                proposal = try store.engine.redistributionProposal(row, from: destination, through: distributionEnd, in: store.data)
                                confirmDistribution = true
                            } catch { store.errorMessage = store.t((error as? PlanError)?.errorDescription ?? "validation.data") }
                        }
                        ForEach(proposal, id: \.day) { item in Text(item.day + ": " + item.target.formatted(.number.locale(store.locale)) + " " + store.t(row.unit)) }
                        ForEach(["skipped", "cancelled"], id: \.self) { status in
                            Button(store.t(status)) {
                                if store.change({ data in if let i = data.occurrences.firstIndex(where: { $0.id == id }) { data.occurrences[i].status = status } }) { dismiss() }
                            }
                        }
                    }.disabled(!["planned", "partial"].contains(row.status))
                }
            }.keyboardDone().navigationTitle(store.t("task.detail"))
                .toolbar { Button(store.t("close")) { dismiss() } }
                .onAppear { value = store.data.occurrences.first { $0.id == id }?.value ?? 0 }
                .confirmationDialog(store.t("redistribute.confirm"), isPresented: $confirmDistribution) {
                    Button(store.t("redistribute")) {
                        let planner = store.engine
                        if store.change({ try planner.redistribute(id, from: destination, through: distributionEnd, in: &$0) }) { dismiss() }
                    }
                }
                .confirmationDialog(store.t("move.confirm"), isPresented: $confirmMove) {
                    Button(store.t("move")) {
                        let planner = store.engine
                        if store.change({ try planner.move(id, to: destination, in: &$0) }) { dismiss() }
                    }
                }
        }
    }
}
