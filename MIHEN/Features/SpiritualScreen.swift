import SwiftUI
import UIKit

struct SpiritualScreen: View {
    @Environment(AppStore.self) private var store
    var body: some View {
        List {
            Section {
                NavigationLink(destination: KhatmScreen()) { Label(store.t("quran.khatm"), systemImage: "book") }.accessibilityIdentifier("spiritual.khatm")
                NavigationLink(destination: MemorizationScreen()) { Label(store.t("memorization"), systemImage: "brain.head.profile") }.accessibilityIdentifier("spiritual.memorization")
                NavigationLink(destination: DhikrScreen()) { Label(store.t("dhikr"), systemImage: "circle.grid.3x3") }.accessibilityIdentifier("spiritual.dhikr")
                NavigationLink(destination: FastingScreen()) { Label(store.t("fasting"), systemImage: "moon") }.accessibilityIdentifier("spiritual.fasting")
                NavigationLink(destination: QadaScreen()) { Label(store.t("qada"), systemImage: "moon.stars") }.accessibilityIdentifier("spiritual.qada")
            }
            Section { Text(store.t("spiritual.explanation")).font(.footnote) }
            Section(store.t("templates")) {
                NavigationLink(destination: SpiritualTemplatesScreen()) { Text(store.t("templates.choose")) }
            }
        }.keyboardDone().navigationTitle(store.t("spiritual"))
    }
}
struct KhatmScreen: View {
    @Environment(AppStore.self) private var store
    @State private var add = false
    @State private var edit: QuranKhatmRecord?
    var body: some View {
        List {
            if store.data.khatms.isEmpty { EmptyState(key: "empty.khatm") }
            ForEach(store.data.khatms) { khatm in
                NavigationLink(destination: KhatmDetail(khatmID: khatm.id)) {
                    let pages = store.data.readings.filter { $0.khatmID == khatm.id }.reduce(0) { $0 + $1.pages }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(khatm.title).font(.headline)
                        Text(store.t(khatm.kind)).font(.caption)
                        ProgressView(value: Double(pages) / Double(khatm.totalPages))
                        Text("\(pages) / \(khatm.totalPages) " + store.t("pages"))
                    }
                }.swipeActions { Button(store.t("edit")) { edit = khatm } }
            }
            Section { Text(store.t("khatm.explanation")).font(.footnote) }
        }.keyboardDone().navigationTitle(store.t("quran.khatm"))
            .toolbar { Button { add = true } label: { Image(systemName: "plus") }.accessibilityIdentifier("khatm.add") }
            .sheet(isPresented: $add) { KhatmEditor() }
            .sheet(item: $edit) { KhatmEditor(khatm: $0) }
    }
}
struct KhatmEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: QuranKhatmRecord
    @State private var deleting = false
    init(khatm: QuranKhatmRecord? = nil) { _draft = State(initialValue: khatm ?? .init(end: Calendar.current.date(byAdding: .year, value: 1, to: Date())!)) }
    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("title"), text: $draft.title).autocorrectionDisabled().accessibilityIdentifier("khatm.title")
                Picker(store.t("type"), selection: $draft.kind) { ForEach(["reading", "translation", "tafsir"], id: \.self) { Text(store.t($0)).tag($0) } }
                IntegerInput(title: "pages.total", value: $draft.totalPages)
                DatePicker(store.t("start.date"), selection: $draft.start, displayedComponents: .date)
                DatePicker(store.t("end.date"), selection: $draft.end, displayedComponents: .date)
                TextEditor(text: $draft.notes).frame(minHeight: 80).accessibilityLabel(store.t("notes"))
                if store.data.khatms.contains(where: { $0.id == draft.id }) { Button(store.t("delete"), role: .destructive) { deleting = true } }
            }.keyboardDone().navigationTitle(store.t("quran.khatm"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        if store.change({ data in if let i = data.khatms.firstIndex(where: { $0.id == draft.id }) { data.khatms[i] = draft } else { data.khatms.append(draft) } }) { dismiss() }
                    }.disabled(draft.title.isEmpty || draft.totalPages <= 0 || draft.end < draft.start).accessibilityIdentifier("khatm.save") }
                }
                .confirmationDialog(store.t("delete.confirm"), isPresented: $deleting) { Button(store.t("delete"), role: .destructive) {
                    if store.change({ data in data.khatms.removeAll { $0.id == draft.id }; data.readings.removeAll { $0.khatmID == draft.id } }) { dismiss() }
                } }
        }
    }
}
struct KhatmDetail: View {
    @Environment(AppStore.self) private var store
    let khatmID: String
    @State private var pages = 1
    @FocusState private var readingFocused: Bool
    var body: some View {
        Form {
            if let khatm = store.data.khatms.first(where: { $0.id == khatmID }) {
                let total = store.data.readings.filter { $0.khatmID == khatmID }.reduce(0) { $0 + $1.pages }
                Section(khatm.title) {
                    Text("\(total) / \(khatm.totalPages) " + store.t("pages"))
                    ProgressView(value: Double(total) / Double(khatm.totalPages))
                    Text(store.t("juz.approximate") + ": " + min(30, Double(total) / Double(khatm.totalPages) * 30).formatted(.number.precision(.fractionLength(1)).locale(store.locale)))
                    Text(store.t("daily.suggestion") + ": " + store.engine.remainingPerDay(total: Double(khatm.totalPages), completed: Double(total), start: khatm.start, end: khatm.end, now: Date()).formatted(.number.locale(store.locale)) + " " + store.t("pages"))
                    if let completed = khatm.completedAt { Text(completed, format: .dateTime.day().month().year()) }
                }
                Section(store.t("reading.add")) {
                    IntegerInput(title: "pages", value: $pages, fieldID: "khatm.pages")
                    Text(store.t("reading.quantity.help")).font(.footnote)
                    Button(store.t("save")) { store.addReading(khatmID: khatmID, pages: pages); readingFocused = false }.disabled(pages <= 0 || total + pages > khatm.totalPages).accessibilityIdentifier("khatm.reading.save")
                }
                Section(store.t("history")) {
                    ForEach(store.data.readings.filter { $0.khatmID == khatmID }.sorted { $0.date > $1.date }) { row in
                        HStack { Text(row.date, format: .dateTime.day().month()); Spacer(); Text("\(row.pages) " + store.t("pages")) }
                            .swipeActions { Button(store.t("delete"), role: .destructive) {
                                store.change { data in
                                    data.readings.removeAll { $0.id == row.id }
                                    if let i = data.khatms.firstIndex(where: { $0.id == khatmID }) { data.khatms[i].completedAt = nil }
                                }
                            } }
                    }
                }
            }
        }.keyboardDone().navigationTitle(store.t("quran.khatm"))
    }
}
struct MemorizationScreen: View {
    @Environment(AppStore.self) private var store
    @State private var add = false
    @State private var editing: MemorizationItemRecord?
    @State private var lastReview: String?
    var body: some View {
        List {
            if store.data.memorization.isEmpty { EmptyState(key: "empty.memorization") }
            ForEach(store.data.memorization) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Button { editing = item } label: { Text(item.title).font(.headline) }
                    Text("\(item.learnedVerses) / \(item.lastVerse - item.firstVerse + 1) " + store.t("verses"))
                    if let next = store.engine.nextReview(item, reviews: store.data.memorizationReviews) { Text(store.t("review.next") + ": " + next.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: store.locale, calendar: store.engine.calendar, timeZone: store.engine.timeZone))) }
                    else { Text(store.t("review.none")) }
                    Button(store.t("review.record")) {
                        let review=MemorizationReviewRecord(itemID:item.id,difficulty:item.difficulty)
                        if store.change({ $0.memorizationReviews.append(review) }) { lastReview=review.id }
                    }
                    if let lastReview,store.data.memorizationReviews.contains(where:{ $0.id == lastReview && $0.itemID == item.id }) {
                        Button(store.t("undo")) { if store.change({ $0.memorizationReviews.removeAll { $0.id == lastReview } }) { self.lastReview=nil } }.accessibilityIdentifier("review.undo")
                    }
                    DisclosureGroup(store.t("history")) {
                        ForEach(store.data.memorizationReviews.filter { $0.itemID == item.id }.sorted { $0.date > $1.date }) { review in
                            HStack {
                                Text(review.date,format:.dateTime.day().month().year().hour().minute())
                                Spacer()
                                Button(store.t("review.remove"),role:.destructive) { store.change { $0.memorizationReviews.removeAll { $0.id == review.id } } }.frame(minHeight:44)
                            }
                        }
                    }
                    if let last = store.data.memorizationReviews.filter({ $0.itemID == item.id }).max(by: { $0.date < $1.date }) { Text(last.date, format: .dateTime.day().month().year()).font(.caption) }
                }.padding(.vertical, 6).buttonStyle(.borderless)
            }
        }.keyboardDone().navigationTitle(store.t("memorization"))
            .toolbar { Button { add = true } label: { Image(systemName: "plus") }.accessibilityIdentifier("memorization.add") }
            .sheet(isPresented: $add) { MemorizationEditor() }
            .sheet(item: $editing) { MemorizationEditor(item: $0) }
    }
}
struct MemorizationEditor: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MemorizationItemRecord
    @State private var intervals = "1,3,7,14,30"
    @State private var deleting = false
    init(item: MemorizationItemRecord? = nil) {
        _draft = State(initialValue: item ?? .init())
        _intervals = State(initialValue: (item?.intervals ?? [1,3,7,14,30]).map(String.init).joined(separator: ","))
    }
    var body: some View {
        NavigationStack {
            Form {
                TextField(store.t("title"), text: $draft.title).autocorrectionDisabled().accessibilityIdentifier("memorization.title")
                IntegerInput(title: "verse.first", value: $draft.firstVerse)
                IntegerInput(title: "verse.last", value: $draft.lastVerse, fieldID: "memorization.last")
                IntegerInput(title: "verses.learned", value: $draft.learnedVerses, fieldID: "memorization.learned")
                Picker(store.t("difficulty"), selection: $draft.difficulty) { ForEach(0..<3) { Text(store.t("difficulty.\($0)")).tag($0) } }
                TextField(store.t("review.intervals"), text: $intervals)
                TextEditor(text: $draft.notes).frame(minHeight: 80).accessibilityLabel(store.t("notes"))
                if store.data.memorization.contains(where: { $0.id == draft.id }) { Button(store.t("delete"), role: .destructive) { deleting = true } }
            }.keyboardDone().navigationTitle(store.t("memorization"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button(store.t("cancel")) { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button(store.t("save")) {
                        let parts = intervals.split(separator: ",", omittingEmptySubsequences: false)
                        let parsed = parts.compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                        guard parsed.count == parts.count else { store.errorMessage = store.t("validation.data"); return }
                        draft.intervals = parsed
                        if store.change({ data in if let i = data.memorization.firstIndex(where: { $0.id == draft.id }) { data.memorization[i] = draft } else { data.memorization.append(draft) } }) { dismiss() }
                    }.disabled(draft.title.isEmpty).accessibilityIdentifier("memorization.save") }
                }
                .confirmationDialog(store.t("delete.confirm"), isPresented: $deleting) { Button(store.t("delete"), role: .destructive) { if store.change({ data in data.memorization.removeAll { $0.id == draft.id }; data.memorizationReviews.removeAll { $0.itemID == draft.id } }) { dismiss() } } }
        }
    }
}
struct DhikrScreen: View {
    @Environment(AppStore.self) private var store
    @State private var title = ""
    @State private var target = 100
    var body: some View {
        List {
            Section(store.t("today")) {
                ForEach(store.data.dhikr.filter { $0.day == store.engine.key(Date()) }) { counter in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(counter.title).font(.headline)
                        Text("\(counter.value) / \(counter.target)").font(.largeTitle.monospacedDigit())
                        HStack(spacing: 24) {
                            Button { change(counter.id, delta: -1) } label: { Image(systemName: "minus.circle").frame(minWidth:44,minHeight:44) }.accessibilityLabel(store.t("decrease"))
                            Button { change(counter.id, delta: 1) } label: { Image(systemName: "plus.circle.fill").font(.largeTitle).frame(minWidth:44,minHeight:44) }.accessibilityLabel(store.t("increase"))
                        }.buttonStyle(.borderless)
                    }.padding(.vertical)
                }
            }
            Toggle(store.t("dhikr.haptics"),isOn:Binding(get:{ store.data.option("dhikr.haptics",fallback:"false") == "true" },set:{ value in store.change { $0.setOption("dhikr.haptics",value:value ? "true" : "false") } }))
            Section(store.t("counter.new")) {
                TextField(store.t("title"), text: $title).autocorrectionDisabled().accessibilityIdentifier("tracker.title")
                IntegerInput(title: "target", value: $target, fieldID: "counter.target")
                Button(store.t("add")) { if store.change({ $0.dhikr.append(.init(title: title, day: store.engine.key(Date()), target: target)) }) { title = "" } }.disabled(title.isEmpty || target <= 0)
            }
            Section(store.t("history")) {
                ForEach(store.data.dhikr.filter { $0.day != store.engine.key(Date()) }.sorted { $0.day > $1.day }) { row in Text("\(row.day) · \(row.title) · \(row.value)/\(row.target)") }
            }
        }.keyboardDone().navigationTitle(store.t("dhikr"))
    }
    private func change(_ id: String, delta: Int) {
        if store.change({ data in if let i = data.dhikr.firstIndex(where: { $0.id == id }) { data.dhikr[i].value = max(0, min(1_000_000, data.dhikr[i].value + delta)) } }), store.data.option("dhikr.haptics",fallback:"false") == "true" { UIImpactFeedbackGenerator(style:.light).impactOccurred() }
    }
}
struct FastingScreen: View {
    @Environment(AppStore.self) private var store
    @State private var title = ""
    @State private var date = Date()
    @FocusState private var titleFocused: Bool
    var body: some View {
        List {
            Section {
                Text(store.t("fasting.calendarNote")).font(.footnote)
                TextField(store.t("title"), text: $title).autocorrectionDisabled().focused($titleFocused).accessibilityIdentifier("tracker.title")
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                Button(store.t("add")) { addPlan() }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).accessibilityIdentifier("fast.add")
            }
            Section(store.t("summary")) {
                Text(store.t("fasting.upcoming") + ": \(store.data.fasts.filter { $0.status == "planned" }.count)")
                Text(store.t("fasting.recorded") + ": \(store.data.fasts.filter { $0.status == "completed" }.count)")
            }
            ForEach(store.data.fasts.sorted { $0.date > $1.date }) { fast in
                VStack(alignment: .leading) {
                    Text(fast.title).font(.headline)
                    Text(fast.date, format: .dateTime.day().month().year())
                    Picker(store.t("status"), selection: Binding(get: { fast.status }, set: { status in store.change { data in if let i = data.fasts.firstIndex(where: { $0.id == fast.id }) { data.fasts[i].status = status } } })) {
                        ForEach(["planned", "completed", "cancelled", "postponed"], id: \.self) { Text(store.t($0)).tag($0) }
                    }.accessibilityIdentifier("fast.status.\(fast.id)")
                }.swipeActions { Button(store.t("delete"), role: .destructive) { store.change { $0.fasts.removeAll { $0.id == fast.id } } } }
            }
        }.keyboardDone().navigationTitle(store.t("fasting"))
    }
    private func addPlan() {
        let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        if store.change({ $0.fasts.append(.init(date: date, title: cleaned)) }) {
            title = ""
            titleFocused = false
        }
    }
}
struct SpiritualTemplatesScreen: View {
    @Environment(AppStore.self) private var store
    @State private var selected = Set<String>()
    private let routines = ["evrad", "dua", "waqia", "mulk", "baqarah", "kahf", "takathur", "allah", "tawhid", "istighfar", "ikhlas", "salawat", "tahajjud", "tunjina", "dalail"]
    var body: some View {
        List {
            Section { Text(store.t("spiritual.explanation")).font(.footnote) }
            Section(store.t("routines")) {
                ForEach(routines, id: \.self) { key in
                    Toggle(store.t("routine.\(key)"), isOn: Binding(get: { selected.contains(key) }, set: { if $0 { selected.insert(key) } else { selected.remove(key) } }))
                }
                Button(store.t("templates.load")) {
                    let planner = store.engine
                    store.change { data in
                        for key in selected where !data.tasks.contains(where: { $0.id == "spiritual:\(key)" || $0.title == "routine.\(key)" }) {
                            let target: Double = key == "allah" ? 1000 : ["tawhid", "istighfar", "ikhlas", "salawat"].contains(key) ? 100 : 1
                            data.tasks.append(.init(id: "spiritual:\(key)", title: "routine.\(key)", domainID: "spiritual", recurrence: key == "tahajjud" ? "weekly" : "daily", target: target, unit: "count", isHabit: true))
                        }
                        planner.materialize(&data, from: Date(), through: Date())
                    }
                }.disabled(selected.isEmpty)
            }
            Section(store.t("quran.khatm")) {
                Text(store.t("khatm.explanation"))
                Button(store.t("khatm.annualTemplates")) {
                    store.change { data in
                        let year = store.engine.calendar.component(.year, from: Date())
                        for i in 1...4 {
                            let title = "\(year) · " + store.t(i == 3 ? "translation" : i == 4 ? "tafsir" : "reading") + " \(i)"
                            if !data.khatms.contains(where: { $0.title == title }) {
                                let end = store.engine.calendar.date(from: DateComponents(year: year, month: 12, day: 31, hour: 23, minute: 59))!
                                data.khatms.append(.init(title: title, kind: i == 3 ? "translation" : i == 4 ? "tafsir" : "reading", end: end))
                            }
                        }
                    }
                }
            }
            Section(store.t("memorization")) {
                Button(store.t("memorization.templates")) {
                    store.change { data in
                        let values = [("Vâkıa", 96), ("Mülk", 30), ("Yâsin", 83), ("Duha", 11), ("İnşirah", 8), ("Tin", 8), ("Alak", 19), ("Kadir", 5), ("Beyyine", 8), ("Zilzal", 8), ("Adiyat", 11), ("Karia", 11), ("Tekâsür", 8), ("Asr", 3), ("Hümeze", 9), ("Fil", 5), ("Kureyş", 4), ("Maun", 7), ("Kevser", 3), ("Kafirun", 6), ("Nasr", 3), ("Tebbet", 5), ("İhlâs", 4), ("Felak", 5), ("Nas", 6)]
                        for (title, verses) in values where !data.memorization.contains(where: { $0.title == title }) { data.memorization.append(.init(title: title, lastVerse: verses)) }
                    }
                }
            }
        }.keyboardDone().navigationTitle(store.t("templates"))
    }
}
