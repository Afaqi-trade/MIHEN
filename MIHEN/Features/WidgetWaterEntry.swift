import SwiftUI

/// Widget links only open this form; the user explicitly records water in the unlocked app.
struct WidgetWaterEntry: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let requestedDay: String?
    @State private var amount=250.0
    @State private var displayedDate=Date()
    var body: some View {
        NavigationStack {
            Form {
                Text(store.t("water.widget.help"))
                Text(displayedDate,format:.dateTime.day().month().year())
                if requestedDay != store.engine.key(displayedDate) { Text(store.t("water.widget.stale")).font(.footnote) }
                ValueInput(title:"amount",value:$amount)
                Text("ml")
                Button(store.t("save")) {
                    let now=Date(),engine=store.engine
                    guard engine.key(now) == engine.key(displayedDate) else { displayedDate=now;return }
                    if store.change({ try $0.saveNutrition(date:now,kind:"water",amount:amount,meal:"other",title:"",note:"",engine:engine) }) { dismiss() }
                }.disabled(amount <= 0 || amount > 2000 || !amount.isFinite)
            }.keyboardDone().navigationTitle(store.t("water.widget"))
                .toolbar { Button(store.t("cancel")) { dismiss() } }
        }
    }
}
