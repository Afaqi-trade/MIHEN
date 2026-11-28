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
    @State private var loaded = false
    @State private var persisted: PrayerSettings?
    private var settings: PrayerSettings { .init(latitude: latitude, longitude: longitude, timeZoneID: zone, method: method, hanafi: hanafi, highLatitude: rule) }
    private var cityLabel: String {
        if let city=PrayerCity.match(latitude:latitude,longitude:longitude,zone:zone) { return city.name+" · "+city.country }
        return store.t("prayer.city.manual")+" · "+zone
    }
    var body: some View {
        Form {
            Section(store.t("prayer.times")) {
                Text(cityLabel).font(.headline)
                if persisted == nil { Text(store.t("prayer.widget.default.explanation")).font(.caption).foregroundStyle(.secondary) }
                Text(store.t(persisted == settings ? "prayer.location.saved" : "prayer.location.preview")).font(.caption).foregroundStyle(.secondary)
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
                NavigationLink(destination:PrayerCityPicker { city in latitude=city.latitude;longitude=city.longitude;zone=city.zone;saved=false }) { Text(store.t("prayer.city.choose")) }.accessibilityIdentifier("prayer.city.choose")
                Text(store.t("prayer.city.help")).font(.footnote)
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
                    do { try PrayerSettingsStore.save(settings); saved = true; persisted=settings; WidgetCenter.shared.reloadAllTimelines() }
                    catch { store.errorMessage = error.localizedDescription }
                }.disabled(settings.schedule(on: date).isEmpty)
                if saved && settings == persisted { Text(store.t("prayer.saved")) }
            }

        }.keyboardDone().navigationTitle(store.t("prayer.times"))
            .onAppear {
                guard !loaded else { return };loaded=true
                #if DEBUG
                let arguments = ProcessInfo.processInfo.arguments
                if arguments.contains("--ui-testing"), let index = arguments.firstIndex(of: "--prayer-test-date"), arguments.indices.contains(index + 1), let fixed = ISO8601DateFormatter().date(from: arguments[index + 1]) { date = fixed }
                #endif
                if let settings = PrayerSettingsStore.read() {
                    persisted=settings
                    latitude = settings.latitude; longitude = settings.longitude; zone = settings.timeZoneID
                    method = settings.method; hanafi = settings.hanafi; rule = settings.highLatitude
                }
            }
    }
}

struct PrayerCityPicker: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var query=""
    let select: (PrayerCity) -> Void
    private var cities: [PrayerCity] { PrayerCity.all.filter { query.isEmpty || ($0.name+" "+$0.country).localizedStandardContains(query) } }
    var body: some View {
        List(cities) { city in
            Button { select(city);dismiss() } label: {
                VStack(alignment:.leading) { Text(city.name);Text(city.country+" · "+city.zone).font(.caption) }
            }.accessibilityIdentifier("city."+city.id)
        }.searchable(text:$query,prompt:store.t("prayer.city.search")).navigationTitle(store.t("prayer.city.choose"))
    }
}
