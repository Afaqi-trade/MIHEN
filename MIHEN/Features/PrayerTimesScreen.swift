import SwiftUI
import WidgetKit

struct PrayerTimesScreen: View {
    @Environment(AppStore.self) private var store
    @State private var latitude = 41.0082
    @State private var longitude = 28.9784
    @State private var zone = "Europe/Istanbul"
    @State private var method = "turkey"
    @State private var hanafi = false
    @State private var rule = "middleOfTheNight"
    @State private var date = Date()
    @State private var saved = false
    private var settings: PrayerSettings { .init(latitude: latitude, longitude: longitude, timeZoneID: zone, method: method, hanafi: hanafi, highLatitude: rule) }
    var body: some View {
        Form {
            Section(store.t("prayer.times")) {
                Text(store.t("prayer.current.city")).font(.caption).foregroundStyle(.secondary)
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                let schedule = settings.schedule(on: date)
                if schedule.isEmpty { Text(store.t("prayer.unavailable")) }
                ForEach(schedule, id: \.key) { item in
                    HStack {
                        Text(store.t("prayer." + item.key)); Spacer()
                        Text(settings.displayTime(item.date))
                    }
                }
            }
            DisclosureGroup(store.t("report.formula")) {
                Text(store.t("prayer.source"))
                Link(store.t("prayer.diyanet"), destination: URL(string: "https://namazvakitleri.diyanet.gov.tr")!)
                Text(store.t("prayer.manual.location")).font(.footnote)
            }
            DisclosureGroup(store.t("prayer.settings")) {
                Button(store.t("prayer.istanbul")) { latitude = 41.0082; longitude = 28.9784; zone = "Europe/Istanbul"; method = "turkey"; saved = false }
                ValueInput(title: "latitude", value: $latitude)
                ValueInput(title: "longitude", value: $longitude)
                NavigationLink(destination: TimeZonePickerScreen(selection: $zone)) { LabeledContent(store.t("timezone"), value: zone) }
                Picker(store.t("prayer.method"), selection: $method) {
                    ForEach(CalculationMethod.allCases.filter { $0 != .other }, id: \.rawValue) { Text(store.t("method." + $0.rawValue)).tag($0.rawValue) }
                }
                Picker(store.t("prayer.hanafi"), selection: $hanafi) {
                    Text(store.t("prayer.asr.standard")).tag(false)
                    Text(store.t("prayer.asr.hanafi")).tag(true)
                }
                Picker(store.t("prayer.highLatitude"), selection: $rule) {
                    ForEach(HighLatitudeRule.allCases, id: \.rawValue) { Text(store.t("rule." + $0.rawValue)).tag($0.rawValue) }
                }
                Button(store.t("save")) {
                    do { try PrayerSettingsStore.save(settings); saved = true; WidgetCenter.shared.reloadAllTimelines() }
                    catch { store.errorMessage = error.localizedDescription }
                }.disabled(settings.schedule(on: date).isEmpty)
                if saved { Text(store.t("prayer.saved")) }
            }

        }.keyboardDone().navigationTitle(store.t("prayer.times"))
            .onAppear {
                #if DEBUG
                let arguments = ProcessInfo.processInfo.arguments
                if arguments.contains("--ui-testing"), let index = arguments.firstIndex(of: "--prayer-test-date"), arguments.indices.contains(index + 1), let fixed = ISO8601DateFormatter().date(from: arguments[index + 1]) { date = fixed }
                #endif
                if let settings = PrayerSettingsStore.read() {
                    latitude = settings.latitude; longitude = settings.longitude; zone = settings.timeZoneID
                    method = settings.method; hanafi = settings.hanafi; rule = settings.highLatitude
                }
            }
    }
}
