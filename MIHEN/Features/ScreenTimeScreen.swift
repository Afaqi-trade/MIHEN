import SwiftUI
import FamilyControls

struct ScreenTimeScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase
    @State private var controller = ScreenTimeController()
    @State private var selection = FamilyActivitySelection()
    @State private var minutes = 60
    @State private var temporaryMinutes = 15
    @State private var picker = false
    @State private var approveTemporary = false
    @State private var approveDisable = false
    var body: some View {
        Form {
            Section {
                Text(store.t("screen.explanation"))
                Text(store.t("screen.device.requirement")).font(.footnote)
            }
            Section(store.t("screen.status")) {
                Text(store.t(controller.authorized ? "screen.authorized" : "screen.unauthorized"))
                if controller.loaded {
                    Text(store.t(controller.document.policy.enabled ? controller.blocked ? "screen.blocked" : "screen.enabled" : "screen.disabled"))
                    if let until = controller.document.policy.temporaryUntil, until > Date() {
                        Text(store.t("screen.open.until"))
                        Text(until, format: .dateTime.hour().minute())
                    }
                }
                if let key = controller.errorKey { Text(store.t(key)).foregroundStyle(.red).accessibilityIdentifier("screen.error") }
                if !controller.authorized {
                    Button(store.t("screen.authorize")) { Task { await controller.authorize() } }.disabled(controller.busy)
                }
            }
            Section(store.t("screen.daily")) {
                Stepper(store.t("minutes") + ": \(minutes)", value: $minutes, in: 1...720)
                Button(store.t("screen.select")) { picker = true }.disabled(!controller.authorized)
                Text(store.t("screen.selection.count") + ": \(selection.applicationTokens.count) / \(selection.categoryTokens.count) / \(selection.webDomainTokens.count)").font(.caption)
                Button(store.t("screen.enable")) { controller.enable(selection: selection, minutes: minutes) }
                    .disabled(!controller.authorized || !controller.loaded || controller.busy || (selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty && selection.webDomainTokens.isEmpty))
            }.disabled(controller.document.policy.enabled)
            if controller.document.policy.enabled || (!controller.loaded && controller.authorized) {
                Section(store.t("screen.temporary")) {
                    Picker(store.t("minutes"), selection: $temporaryMinutes) { ForEach([15, 30, 60], id: \.self) { Text("\($0)").tag($0) } }
                    Button(store.t("screen.open")) { approveTemporary = true }.disabled(!controller.blocked || controller.busy)
                    Text(store.t("screen.temporary.explanation")).font(.footnote)
                    Button(store.t("screen.disable"), role: .destructive) { approveDisable = true }.disabled(controller.busy)
                }
            }
            Button(store.t("screen.refresh")) { reload() }.disabled(controller.busy)
        }.navigationTitle(store.t("screen.title"))
            .familyActivityPicker(isPresented: $picker, selection: $selection)
             .task {
                reload()
                while !Task.isCancelled {
                    do { try await Task.sleep(for: .seconds(15)) } catch { break }
                    if scenePhase == .active && !controller.busy { controller.refresh() }
                }
            }
            .onChange(of: scenePhase) { _, phase in if phase == .active && !controller.busy { reload() } }
            .confirmationDialog(store.t("screen.approve.temporary"), isPresented: $approveTemporary) {
                Button(store.t("continue")) { Task { await controller.temporarilyOpen(minutes: temporaryMinutes, reason: store.t("screen.auth.reason")) } }
            }
            .confirmationDialog(store.t("screen.approve.disable"), isPresented: $approveDisable) {
                Button(store.t("screen.disable"), role: .destructive) { Task { await controller.disable(reason: store.t("screen.auth.reason")) } }
            }
    }
    private func reload() {
        controller.refresh()
        if controller.loaded { selection = controller.document.selection; minutes = controller.document.policy.minutes }
    }
}
