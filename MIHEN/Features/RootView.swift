import SwiftUI

struct RootView: View {
    @Bindable var store: AppStore
    @State private var tab = 0
    @State private var prayers = false
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        ZStack {
            Group {
                if store.preferences.onboarded {
                    TabView(selection: $tab) {
                        NavigationStack { TodayView() }.tabItem { Label(store.t("today"), systemImage: "house") }.tag(0)
                        NavigationStack { PlanView() }.tabItem { Label(store.t("plan"), systemImage: "target") }.tag(1)
                        NavigationStack { CalendarScreen() }.tabItem { Label(store.t("calendar"), systemImage: "calendar") }.tag(2)
                        NavigationStack { ProgressScreen() }.tabItem { Label(store.t("progress"), systemImage: "chart.bar") }.tag(3)
                        NavigationStack { SettingsScreen() }.tabItem { Label(store.t("profile"), systemImage: "person") }.tag(4)
                    }
                } else { OnboardingView() }
            }
            .disabled(store.locked)
            .accessibilityHidden(store.locked)
            if store.locked { lockView }
            // Cover sensitive content in the app switcher, even before optional lock is enabled.
            if scenePhase != .active {
                Color.mihenBackground.ignoresSafeArea()
                BrandMark().frame(width: 100, height: 100)
            }
        }
        .environment(store)
        .environment(\.locale, store.locale)
        .environment(\.calendar, store.engine.calendar)
        .environment(\.timeZone, store.engine.timeZone)
        .preferredColorScheme(store.colorScheme)
        .tint(.mihenGreen)
        .alert(store.t("error"), isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
            Button(store.t("ok")) { store.errorMessage = nil }
        } message: { Text(store.errorMessage ?? "") }
        .sheet(isPresented: $prayers) { NavigationStack { PrayerTimesScreen().toolbar { Button(store.t("close")) { prayers = false } } } }
        .onOpenURL { url in if url.scheme == "mihen" { tab = 0; if url.host == "prayers" && !store.locked { prayers = true } } }
        .task { ScreenTimeController.reconcileOnForeground(); if !store.locked { store.refresh() } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background && store.preferences.lockEnabled { store.locked = true }
            if phase == .active { ScreenTimeController.reconcileOnForeground(); if !store.locked { store.refresh() } }
        }
    }
    private var lockView: some View {
        VStack(spacing: 24) {
            BrandMark().frame(width: 100, height: 100)
            Text("MİHEN").font(.largeTitle.bold())
            Button(store.t("unlock"), systemImage: "faceid") {
                Task {
                    do { if try await AppLock.authenticate(reason: store.t("lock.reason")) { store.locked = false; store.refresh() } }
                    catch { store.errorMessage = error.localizedDescription }
                }
            }.buttonStyle(.borderedProminent)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.mihenBackground.ignoresSafeArea())
    }
}

struct OnboardingView: View {
    @Environment(AppStore.self) private var store
    @State private var name = ""
    @State private var selected = Set(LifeArea.allCases.map(\.rawValue))
    @State private var templates = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        BrandMark().frame(width: 90, height: 90)
                        Text("MİHEN").font(.largeTitle.bold())
                        Text(store.t("slogan")).font(.title3)
                        Text(store.t("onboarding.body")).foregroundStyle(.secondary)
                    }.padding(.vertical)
                    TextField(store.t("name"), text: $name).textContentType(.givenName)
                }
                Section(store.t("priorities")) {
                    ForEach(LifeArea.allCases, id: \.rawValue) { area in
                        Toggle(store.title(area.rawValue), isOn: Binding(get: { selected.contains(area.rawValue) }, set: { if $0 { selected.insert(area.rawValue) } else { selected.remove(area.rawValue) } }))
                    }
                }
                Section {
                    Toggle(store.t("templates.load"), isOn: $templates)
                    Text(store.t("templates.explanation")).font(.footnote)
                    Button(store.t("start")) { finish() }.accessibilityIdentifier("onboarding.start")
                }
            }
            .toolbar { Button(store.t("skip")) { templates = false; finish() }.accessibilityIdentifier("onboarding.skip") }
        }
    }
    private func finish() {
        let planner = store.engine
        store.change { data in
            data.preferences[0].name = name
            data.preferences[0].onboarded = true
            for i in data.domains.indices { data.domains[i].enabled = selected.contains(data.domains[i].key) }
            if templates { data.addStarterTemplates(on: Date(), engine: planner) }
        }
    }
}
