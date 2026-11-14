import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store
    @State private var taskEditor = false
    @State private var noteEditor = false
    private var today: Date { Date() }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(today, format: .dateTime.weekday(.wide).day().month(.wide).year()).foregroundStyle(.secondary)
                if store.preferences.showHijri {
                    Text(hijriDate).font(.subheadline).foregroundStyle(.secondary)
                }
                summaryCard
                HStack {
                    Text(store.t("today.plan")).font(.title2.bold())
                    Spacer()
                    NavigationLink(destination: TaskListScreen()) { Text(store.t("manage")) }
                }
                if store.occurrences(on: today).isEmpty { EmptyState(key: "empty.tasks") }
                ForEach(store.occurrences(on: today)) { OccurrenceRow(occurrence: $0) }
                NavigationLink(destination: SpiritualScreen()) { Label(store.t("spiritual"), systemImage: "sparkles").mihenCard() }
                Button { noteEditor = true } label: { Label(store.t("quick.note"), systemImage: "square.and.pencil").mihenCard() }
                let events = store.data.events.filter { $0.date >= today }.sorted { $0.date < $1.date }
                if !events.isEmpty {
                    Text(store.t("upcoming")).font(.title2.bold())
                    ForEach(Array(events.prefix(3))) { event in
                        VStack(alignment: .leading) { Text(event.title); Text(event.date, format: .dateTime.day().month().hour().minute()).font(.caption).foregroundStyle(.secondary) }.mihenCard()
                    }
                }
                NavigationLink(destination: JournalScreen()) { Text(store.t("reviews")) }
            }.padding()
        }
        .background(Color.mihenBackground)
        .navigationTitle(greeting)
        .toolbar {
            Button { taskEditor = true } label: { Image(systemName: "plus") }.accessibilityLabel(store.t("task.new")).accessibilityIdentifier("today.add")
        }
        .sheet(isPresented: $taskEditor) { TaskEditor() }
        .sheet(isPresented: $noteEditor) { JournalEditor(kind: "note") }
    }
    private var greeting: String {
        let hour = store.engine.calendar.component(.hour, from: today)
        return store.t(hour < 12 ? "greeting.morning" : hour < 18 ? "greeting.day" : "greeting.evening") + (store.preferences.name.isEmpty ? "" : ", \(store.preferences.name)")
    }
    private var hijriDate: String {
        let formatter = DateFormatter()
        formatter.calendar = store.engine.hijriCalendar
        formatter.locale = store.locale
        formatter.timeZone = store.engine.timeZone
        formatter.dateStyle = .long
        return formatter.string(from: store.engine.addingDays(store.preferences.hijriOffset, to: today))
    }
    private var summaryCard: some View {
        let summary = store.engine.summary(store.data, on: today)
        return VStack(alignment: .leading, spacing: 16) {
            Text(store.t("daily.progress")).font(.headline)
            Text(summary.ratio.map { $0.formatted(.percent.precision(.fractionLength(0)).locale(store.locale)) } ?? "—").font(.system(.largeTitle, design: .rounded, weight: .bold)).accessibilityIdentifier("today.progress")
            Text("\(summary.completed) / \(summary.planned) " + store.t("tasks.completed"))
            ProgressView(value: summary.ratio ?? 0).tint(.white)
            Text(store.t("top.three")).font(.subheadline.bold())
            ForEach(Array(store.occurrences(on: today).filter { ["planned", "partial"].contains($0.status) }.prefix(3))) { Text("• " + store.taskTitle($0.title)).font(.subheadline) }
        }.padding(24).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.white)
            .background(Color.mihenNavy.gradient, in: RoundedRectangle(cornerRadius: 28))
    }
}

struct OccurrenceRow: View {
    @Environment(AppStore.self) private var store
    let occurrence: TaskOccurrenceRecord
    @State private var details = false
    private var active: Bool { ["planned", "partial", "completed"].contains(occurrence.status) }
    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.progress(occurrence.id, value: occurrence.status == "completed" ? 0 : occurrence.target)
            } label: {
                Image(systemName: occurrence.status == "completed" ? "checkmark.circle.fill" : occurrence.status == "partial" ? "circle.lefthalf.filled" : "circle")
                    .font(.title2).foregroundStyle(occurrence.status == "completed" ? Color.mihenGreen : .secondary)
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
                Button { store.progress(occurrence.id, value: max(0, occurrence.value - 1)) } label: { Image(systemName: "minus") }
                    .accessibilityLabel(store.t("decrease"))
                Button { store.progress(occurrence.id, value: occurrence.value + 1) } label: { Image(systemName: "plus") }
                    .accessibilityLabel(store.t("increase"))
            }
        }.mihenCard()
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
