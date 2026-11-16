import SwiftUI

struct SourceLinkScreen: View {
    @Environment(AppStore.self) private var store
    let occurrenceID: String
    @State private var pending: SourceEvent?
    private var row: TaskOccurrenceRecord? { store.data.occurrences.first { $0.id == occurrenceID } }
    private var link: SourceLinkRecord? { store.data.sourceLinks.first { $0.occurrenceID == occurrenceID } }
    private var events: [SourceEvent] {
        guard let row else { return [] }
        return store.data.sourceEvents(engine:store.engine).filter { event in
            event.domainID == row.domainID && event.unit == row.unit && store.engine.key(event.date) == row.day && event.amount > 0 && !store.data.sourceLinks.contains { $0.sourceKind == event.kind && $0.sourceID == event.sourceID }
        }.sorted { $0.date > $1.date }
    }
    var body: some View {
        List {
            Text(store.t("source.explanation")).font(.subheadline)
            if let row {
                Section(store.taskTitle(row.title)) {
                    Text(row.value.formatted(.number.locale(store.locale))+" / "+row.target.formatted(.number.locale(store.locale))+" "+store.t(row.unit)).accessibilityIdentifier("source.current")
                    Text(row.day)
                }
                if let link {
                    if let event=store.data.sourceEvents(engine:store.engine).first(where: { $0.kind == link.sourceKind && $0.sourceID == link.sourceID }) {
                        Section(store.t("source.connected")) {
                            Text(store.taskTitle(event.title))
                            Text(event.amount.formatted(.number.locale(store.locale))+" "+store.t(event.unit))
                            NavigationLink(destination:SourceRecordDestination(event:event)) { Text(store.t("source.open")) }
                        }
                    }
                    Button(store.t("source.disconnect")) {
                        let engine=store.engine
                        if store.change({ try $0.disconnectSource(link.id,engine:engine) }) { store.lastProgressChange=nil }
                    }.accessibilityIdentifier("source.disconnect")
                    Text(store.t("source.restore")).font(.footnote)
                } else {
                    Section(store.t("source.available")) {
                        if events.isEmpty { Text(store.t("source.empty")) }
                        ForEach(events) { event in
                            Button { pending=event } label: {
                                VStack(alignment:.leading) {
                                    Text(store.taskTitle(event.title))
                                    Text(store.t("source.kind."+event.kind)+" · "+event.amount.formatted(.number.locale(store.locale))+" "+store.t(event.unit)).font(.caption)
                                }
                            }.accessibilityIdentifier("source.choose."+event.kind)
                        }
                    }
                }
            }
        }.navigationTitle(store.t("source.title"))
            .confirmationDialog(store.t("source.confirmation"),isPresented:Binding(get:{ pending != nil },set:{ if !$0 { pending=nil } })) {
                Button(store.t("source.connect")) {
                    guard let event=pending else { return };let engine=store.engine
                    if store.change({ try $0.connectSource(event.id,to:occurrenceID,engine:engine) }) { store.lastProgressChange=nil }
                    pending=nil
                }.accessibilityIdentifier("source.confirm")
            }
    }
}
private struct SourceRecordDestination: View {
    let event: SourceEvent
    @Environment(AppStore.self) private var store
    @ViewBuilder var body: some View {
        switch event.kind {
        case "reading":
            if let reading=store.data.readings.first(where: { $0.id == event.sourceID }) { KhatmDetail(khatmID:reading.khatmID) }
        case "review": MemorizationScreen()
        case "dhikr": DhikrScreen()
        case "fast": FastingScreen()
        default:
            if ["kcal","ml"].contains(event.unit) { NutritionScreen() }
            else { DomainActivityScreen(domainID:event.domainID) }
        }
    }
}
