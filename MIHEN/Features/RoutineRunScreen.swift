import SwiftUI

struct RoutineRunScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let routineID: String
    @State private var sessionID: String?
    private var session: RoutineSessionRecord? { store.data.routineSessions.first { $0.id == sessionID } }
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing:20) {
                Text(store.t("routine.run.help"))
                if let session {
                    let current = store.data.occurrences.filter { $0.day == session.day && session.taskIDs.contains($0.taskID) }
                    let completed = current.filter { $0.status == "completed" }.count
                    let partial = current.filter { $0.status == "partial" }.count
                    Text(store.t("routine.run.recorded") + ": \(completed) / \(session.taskIDs.count) · " + store.t("report.partial") + ": \(partial)")
                        .font(.subheadline).accessibilityIdentifier("routine.recorded")
                    Text("\(min(session.position+1,session.taskIDs.count)) / \(session.taskIDs.count)").font(.title2).accessibilityIdentifier("routine.position")
                    if session.position < session.taskIDs.count {
                        let taskID=session.taskIDs[session.position]
                        if let row=store.data.occurrences.first(where: { $0.taskID == taskID && $0.day == session.day }) {
                            OccurrenceRow(occurrence:row)
                        } else { Text(store.t("routine.step.missing")) }
                        Button(store.t("routine.next")) { advance(session) }.buttonStyle(.borderedProminent).accessibilityIdentifier("routine.next")
                    } else { Text(store.t("routine.end")).font(.headline) }
                    if session.position > 0 {
                        Button(store.t("back")) {
                            store.change { data in if let i=data.routineSessions.firstIndex(where: { $0.id == session.id }) { data.routineSessions[i].position -= 1 } }
                        }
                    }
                    Button(store.t("routine.run.leave")) { dismiss() }.accessibilityIdentifier("routine.leave")
                    Text(store.t("routine.run.leave.help")).font(.footnote).foregroundStyle(.secondary)
                } else { Text(store.t("routine.unavailable")) }
            }.padding()
        }.background(Color.mihenBackground).navigationTitle(store.data.routines.first { $0.id == routineID }?.title ?? store.t("routines"))
            .onAppear {
                let engine=store.engine
                store.change { data in sessionID=try engine.beginRoutine(routineID,on:Date(),in:&data) }
            }
    }
    private func advance(_ session: RoutineSessionRecord) {
        store.change { data in if let i=data.routineSessions.firstIndex(where: { $0.id == session.id }) { data.routineSessions[i].position=min(session.taskIDs.count,session.position+1) } }
    }
}
