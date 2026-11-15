import SwiftUI
import WidgetKit

struct PrayerTimesScreen: View {
    @Environment(AppStore.self) private var store
    @State private var latitude = 0.0
    @State private var longitude = 0.0
    @State private var zone = "Europe/Istanbul"
    @State private var method = "turkey"
    @State private var hanafi = false
    @State private var rule = "middleOfTheNight"
    @State private var date = Date()
    @State private var saved = false
    private var settings: PrayerSettings { .init(latitude: latitude, longitude: longitude, timeZoneID: zone, method: method, hanafi: hanafi, highLatitude: rule) }
    var body: some View {
        Form {
            Section {
                Text(store.t("prayer.source"))
                Link(store.t("prayer.diyanet"), destination: URL(string: "https://namazvakitleri.diyanet.gov.tr")!)
                Text(store.t("prayer.manual.location")).font(.footnote)
            }
            Section(store.t("profile")) {
                ValueInput(title: "latitude", value: $latitude)
                ValueInput(title: "longitude", value: $longitude)
                Picker(store.t("timezone"), selection: $zone) { ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { Text($0).tag($0) } }
                Picker(store.t("prayer.method"), selection: $method) {
                    ForEach(CalculationMethod.allCases.filter { $0 != .other }, id: \.rawValue) { Text(store.t("method." + $0.rawValue)).tag($0.rawValue) }
                }
                Toggle(store.t("prayer.hanafi"), isOn: $hanafi)
                Picker(store.t("prayer.highLatitude"), selection: $rule) {
                    ForEach(HighLatitudeRule.allCases, id: \.rawValue) { Text(store.t("rule." + $0.rawValue)).tag($0.rawValue) }
                }
                Button(store.t("save")) {
                    do { try PrayerSettingsStore.save(settings); saved = true; WidgetCenter.shared.reloadAllTimelines() }
                    catch { store.errorMessage = error.localizedDescription }
                }.disabled(settings.schedule(on: date).isEmpty)
                if saved { Text(store.t("prayer.saved")) }
            }
            Section(store.t("prayer.times")) {
                DatePicker(store.t("date"), selection: $date, displayedComponents: .date)
                let schedule = settings.schedule(on: date)
                if schedule.isEmpty { Text(store.t("prayer.unavailable")) }
                ForEach(schedule, id: \.key) { item in
                    HStack {
                        Text(store.t("prayer." + item.key)); Spacer()
                        Text(item.date, format: Date.FormatStyle(date: .omitted, time: .shortened, locale: store.locale, timeZone: TimeZone(identifier: zone) ?? .current))
                    }
                }
            }
        }.keyboardDone().navigationTitle(store.t("prayer.times"))
            .onAppear {
                if let settings = PrayerSettingsStore.read() {
                    latitude = settings.latitude; longitude = settings.longitude; zone = settings.timeZoneID
                    method = settings.method; hanafi = settings.hanafi; rule = settings.highLatitude
                }
            }
    }
}
