import SwiftUI
import HealthKit

@MainActor @Observable final class HealthSummary {
    var steps: Double?
    var energy: Double?
    var busy = false
    var error: String?
    private let health = HKHealthStore()
    func read(date: Date, calendar: Calendar) async {
        guard HKHealthStore.isHealthDataAvailable(), !busy else { return }
        busy = true
        defer { busy = false }
        steps = nil; energy = nil; error = nil
        let stepType = HKQuantityType(.stepCount)
        let energyType = HKQuantityType(.activeEnergyBurned)
        do {
            try await health.requestAuthorization(toShare: [], read: [stepType, energyType])
            let start = calendar.startOfDay(for: date)
            let end = min(Date(), calendar.date(byAdding: .day, value: 1, to: start)!)
            guard end > start else { return }
            steps = try await sum(stepType, unit: .count(), start: start, end: end)
            energy = try await sum(energyType, unit: .kilocalorie(), start: start, end: end)
        } catch { self.error = error.localizedDescription }
    }
    private func sum(_ type: HKQuantityType, unit: HKUnit, start: Date, end: Date) async throws -> Double? {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: start, end: end), options: .cumulativeSum) { _, result, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit)) }
            }
            health.execute(query)
        }
    }
}
struct HealthSummaryScreen: View {
    @Environment(AppStore.self) private var store
    @State private var summary = HealthSummary()
    @State private var date = Date()
    @State private var confirmImport = false
    @State private var saved = false
    var body: some View {
        Form {
            Text(store.t("health.explanation"))
            DatePicker(store.t("date"), selection: $date, in: ...Date(), displayedComponents: .date)
            Button(store.t("health.read")) { Task { await summary.read(date: date, calendar: store.engine.calendar) } }.disabled(summary.busy)
            if summary.busy { ProgressView() }
            Text(store.t("health.steps") + ": " + (summary.steps.map { $0.formatted(.number.locale(store.locale)) } ?? "—"))
            Text(store.t("health.energy") + ": " + (summary.energy.map { $0.formatted(.number.locale(store.locale)) + " kcal" } ?? "—"))
            Text(store.t("health.source.help")).font(.footnote)
            if summary.steps != nil || summary.energy != nil {
                Button(store.t("health.import")) { confirmImport = true }.disabled(summary.busy)
            }
            if saved { Text(store.t("health.imported")) }
            if let error = summary.error { Text(error).foregroundStyle(.red) }
        }.navigationTitle(store.t("health.connection"))
            .onChange(of: date) { _, _ in summary.steps = nil; summary.energy = nil; saved = false }
            .confirmationDialog(store.t("health.import.confirm"), isPresented: $confirmImport) {
                Button(store.t("health.import")) {
                    let engine = store.engine
                    saved = store.change { try $0.recordHealthSummary(on: date, steps: summary.steps, energy: summary.energy, engine: engine) }
                }
            }
    }
}
