import SwiftUI

struct RootView: View {
    @Bindable var store: AppStore
    @State private var tab = 0
    @State private var prayers = false
    @State private var quickTask = false
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
            .id(store.locked)
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
        .sheet(isPresented: $quickTask) { TaskEditor() }
        .onOpenURL { url in
            if url.scheme == "mihen" {
                tab = 0
                if !store.locked && store.preferences.onboarded {
                    if url.host == "prayers" { prayers = true }
                    if url.host == "add-task" { quickTask = true }
                }
            }
        }
        .task { ScreenTimeController.reconcileOnForeground(); if !store.locked { store.refresh() } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background && store.preferences.lockEnabled { prayers = false; quickTask = false; store.locked = true }
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
    @State private var selected = Set<String>()
    @State private var templates = Set<String>()
    @State private var step = 0
    var body: some View {
        NavigationStack {
            Form {
                if step == 0 {
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            BrandMark().frame(width: 72, height: 72)
                            Text("MİHEN").font(.largeTitle.bold())
                            Text(store.t("slogan")).font(.title3)
                            Text(store.t("welcome.promise")).font(.headline)
                            Text(store.t("welcome.steps"))
                        }.padding(.vertical, 8)
                        TextField(store.t("name"), text: $name).textContentType(.givenName)
                        Text(store.t("welcome.privacy")).font(.footnote).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                } else if step == 1 {
                    Section(store.t("welcome.focus")) {
                        Text(store.t("welcome.focus.help")).font(.footnote)
                        ForEach(LifeArea.allCases, id: \.rawValue) { area in
                            Toggle(store.title(area.rawValue), isOn: Binding(get: { selected.contains(area.rawValue) }, set: { if $0 { selected.insert(area.rawValue) } else { selected.remove(area.rawValue) } })).accessibilityIdentifier("onboarding.area." + area.rawValue)
                        }
                    }
                } else {
                    Section(store.t("templates.choose")) {
                        Text(store.t("starter.explanation")).font(.footnote)
                        ForEach(StarterTemplate.choices) { item in
                            Toggle(isOn: Binding(get: { templates.contains(item.id) }, set: { if $0 { templates.insert(item.id); selected.insert(item.area) } else { templates.remove(item.id) } })) {
                                VStack(alignment: .leading) {
                                    Text(store.t(item.id))
                                    Text(item.target.formatted(.number.locale(store.locale)) + " " + store.t(item.unit) + " · " + store.t("daily")).font(.caption)
                                }
                            }.accessibilityIdentifier("onboarding." + item.id)
                        }
                    }
                    Text("\(templates.count) " + store.t("starter.selected"))
                    Button(store.t("welcome.begin")) { finish() }.buttonStyle(.borderedProminent).accessibilityIdentifier("onboarding.start")
                }
                if step < 2 {
                    Button { step += 1 } label: {
                        Text(store.t("continue")).fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent).accessibilityIdentifier("onboarding.continue")
                }
                if step > 0 { Button(store.t("back")) { step -= 1 } }
            }.keyboardDone().navigationTitle(step == 0 ? "MİHEN" : store.t("welcome.title")).navigationBarTitleDisplayMode(.inline)
                .toolbar { Button { templates = []; selected = Set(LifeArea.allCases.map(\.rawValue)); finish() } label: { Label(store.t("skip"), systemImage: "arrow.right.to.line").labelStyle(.iconOnly) }.accessibilityIdentifier("onboarding.skip") }
        }
    }
    private func finish() {
        let planner = store.engine
        store.change { data in
            data.preferences[0].name = name
            data.preferences[0].onboarded = true
            for i in data.domains.indices { data.domains[i].enabled = selected.contains(data.domains[i].key) }
            data.addSelectedTemplates(templates, on: Date(), engine: planner)
        }
    }
}
