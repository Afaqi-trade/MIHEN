import SwiftUI
import EventKit
import EventKitUI

struct AppleCalendarEditor: UIViewControllerRepresentable {
    let record: CalendarEventRecord
    @Environment(\.dismiss) private var dismiss
    func makeCoordinator() -> Coordinator { Coordinator { dismiss() } }
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        let eventStore = EKEventStore()
        controller.eventStore = eventStore
        let event = EKEvent(eventStore: eventStore)
        event.title = record.title
        event.startDate = record.date
        event.endDate = record.end
        event.notes = record.notes
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) {}
    @MainActor final class Coordinator: NSObject, EKEventEditViewDelegate {
        let finish: () -> Void
        init(finish: @escaping () -> Void) { self.finish = finish }
        nonisolated func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) { Task { @MainActor in self.finish() } }
    }
}
