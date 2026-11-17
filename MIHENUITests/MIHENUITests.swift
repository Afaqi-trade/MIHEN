import XCTest

final class MIHENUITests: XCTestCase {
    @MainActor private func start(persistent: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = persistent ? ["--ui-testing", "--ui-test-store", UUID().uuidString] : ["--ui-testing"]
        app.launchArguments += ["--prayer-test-date", "2026-11-15T12:00:00Z"]
        app.launch()
        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 10))
        skip.tap()
        return app
    }
    @MainActor private func replace(_ field: XCUIElement, with text: String) {
        let app = XCUIApplication()
        if !field.exists {
            let details = app.descendants(matching: .any)["task.details"].firstMatch
            if details.exists { tap(details, in: app) }
        }
        tap(field, in: app)
        let raw = field.value as? String ?? ""
        let value = raw == field.placeholderValue ? "" : raw
        // Number inputs select their full value on focus, as they do for the user.
        // Keep focus while the keyboard repositions the form; screen-edge coordinates
        // can otherwise hit the keyboard or dismiss it after the field has moved.
        app.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count) + text)
        let done = app.buttons["keyboard.done"].firstMatch
        if done.waitForExistence(timeout: 2) && done.isHittable { done.tap() }
        XCTAssertEqual(field.value as? String, text, "Text entry must replace the existing value exactly")
    }
    @MainActor private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        // Toolbar buttons are intentionally inside navigation chrome, not scrolling content.
        func toolbarControl() -> Bool {
            guard element.exists, element.isHittable, !element.identifier.isEmpty else { return false }
            return app.navigationBars.buttons.matching(identifier:element.identifier).allElementsBoundByIndex.contains { $0.frame == element.frame }
        }
        func bounds() -> (CGFloat,CGFloat) {
            let top=app.navigationBars.firstMatch.exists ? app.navigationBars.firstMatch.frame.maxY : app.frame.minY+24
            var bottom=app.frame.maxY-20
            let bar=app.tabBars.firstMatch
            if bar.exists && bar.isHittable { bottom=min(bottom,bar.frame.minY-8) }
            if app.keyboards.firstMatch.exists { bottom=min(bottom,app.keyboards.firstMatch.frame.minY-8) }
            return (top,bottom)
        }
        func visible() -> Bool {
            // System search can be hosted in navigation or bottom search chrome.
            if element.elementType == .searchField && element.exists && element.isHittable { return true }
            if toolbarControl() { return true }
            guard element.exists && element.isHittable else { return false }
            let (top,bottom)=bounds(),frame=element.frame
            // Tap at the element's centre only when it is clear of both bars.
            return frame.midY >= top+4 && frame.midY <= bottom-4
        }
        for index in 0..<20 {
            if visible() { return }
            let (top,bottom)=bounds()
            if element.exists && element.frame.height > 0 {
                let middle=(top+bottom)/2
                let delta=max(-(bottom-top)*0.55,min((bottom-top)*0.55,element.frame.midY-middle))
                let start=app.coordinate(withNormalizedOffset:.zero).withOffset(CGVector(dx:app.frame.midX,dy:middle+delta/2))
                let end=app.coordinate(withNormalizedOffset:.zero).withOffset(CGVector(dx:app.frame.midX,dy:middle-delta/2))
                start.press(forDuration:0.05,thenDragTo:end)
            } else if index >= 12 { app.swipeDown() }
            else { app.swipeUp() }
        }
        XCTAssertTrue(element.waitForExistence(timeout:5))
        XCTAssertTrue(visible(),"The control centre must be clear of navigation, keyboard and tab bar before tapping: \(element.identifier)")
    }
    @MainActor private func tap(_ element: XCUIElement, in app: XCUIApplication) {
        reveal(element, in: app)
        element.tap()
    }
    @MainActor private func spiritual(_ module: String, in app: XCUIApplication) {
        app.tabBars.buttons["Plan"].tap()
        for _ in 0..<4 {
            if app.navigationBars["Plan"].exists { break }
            let back=app.navigationBars.buttons.element(boundBy:0)
            if back.exists { back.tap() }
        }
        XCTAssertTrue(app.navigationBars["Plan"].waitForExistence(timeout:10))
        tap(app.buttons["plan.spiritual"], in: app)
        tap(app.buttons["spiritual." + module], in: app)
    }
    @MainActor func testModuleSourceConnectionRestoresManualProgress() throws {
        let app=start()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"],with:"Kaynaklı adım")
        replace(app.textFields["target"],with:"6")
        app.buttons["task.save"].tap()
        app.buttons["Bir artır"].tap();app.buttons["Bir artır"].tap()
        XCTAssertTrue(app.staticTexts["2 / 6 Adet"].exists)
        spiritual("memorization",in:app)
        app.buttons["memorization.add"].tap()
        replace(app.textFields["memorization.title"],with:"Tekrar kaynağı")
        app.buttons["memorization.save"].tap()
        app.buttons["Tekrar yaptım"].tap()
        app.tabBars.buttons["Bugün"].tap()
        tap(app.buttons.containing(.staticText,identifier:"Kaynaklı adım").firstMatch,in:app)
        tap(app.buttons["source.openLink"],in:app)
        tap(app.buttons["source.choose.review"],in:app)
        tap(app.buttons["source.confirm"],in:app)
        XCTAssertTrue(app.staticTexts["source.current"].waitForExistence(timeout:5))
        XCTAssertEqual(app.staticTexts["source.current"].label,"1 / 6 Adet")
        capture(app,name:"MIHEN-Source-Link-TR")
        app.buttons["source.close"].tap()
        XCTAssertEqual(app.textFields["progress.value"].value as? String,"1")
        XCTAssertFalse(app.textFields["progress.value"].isEnabled)
        tap(app.buttons["source.openLink"],in:app)
        tap(app.buttons["source.disconnect"],in:app)
        XCTAssertEqual(app.staticTexts["source.current"].label,"2 / 6 Adet")
    }
    @MainActor func testRoadmapCapacityRoutineAndNutrition() throws {
        let app=start()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"],with:"Planlı yürüyüş")
        tap(app.descendants(matching:.any)["task.details"].firstMatch,in:app)
        let duration=app.switches["Bu adımın tahmini süresi"]
        reveal(duration,in:app);duration.coordinate(withNormalizedOffset:CGVector(dx:0.9,dy:0.5)).tap()
        XCTAssertEqual(duration.value as? String,"1")
        replace(app.textFields["capacity.minutes"],with:"20")
        app.buttons["task.save"].tap()
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["plan.weekly"],in:app)
        tap(app.buttons["weekly.capacity"],in:app)
        replace(app.textFields["capacity.day.2"],with:"30")
        capture(app,name:"MIHEN-Capacity-TR")
        tap(app.buttons["capacity.save"],in:app)
        tap(app.buttons["Haftanın üç odağını seç"],in:app)
        let focus=app.switches["Planlı yürüyüş"]
        reveal(focus,in:app);focus.coordinate(withNormalizedOffset:CGVector(dx:0.9,dy:0.5)).tap()
        XCTAssertEqual(focus.value as? String,"1")
        app.buttons["weekly.focus.save"].tap()
        capture(app,name:"MIHEN-Weekly-Focus-TR")
        app.navigationBars.buttons.element(boundBy:0).tap()
        tap(app.buttons["plan.routines"],in:app)
        app.buttons["routine.add"].tap()
        replace(app.textFields["routine.title"],with:"Planlı sabah")
        let task=app.switches["Planlı yürüyüş"]
        reveal(task,in:app);task.coordinate(withNormalizedOffset:CGVector(dx:0.9,dy:0.5)).tap()
        XCTAssertEqual(task.value as? String,"1")
        app.buttons["routine.save"].tap()
        tap(app.buttons["routine.start"],in:app)
        XCTAssertTrue(app.staticTexts["routine.position"].waitForExistence(timeout:5))
        capture(app,name:"MIHEN-Routine-Run-TR")
        tap(app.buttons["routine.next"],in:app)
        XCTAssertTrue(app.staticTexts["Sıranın sonuna geldin. Gerçekleşmeler görev kartlarındaki kayıtlarına göre korunur."].exists)
        app.navigationBars.buttons.element(boundBy:0).tap()
        app.navigationBars.buttons.element(boundBy:0).tap()
        tap(app.buttons["Beslenme ve hareket"],in:app)
        tap(app.buttons["Hızlı su miktarlarını ayarla"],in:app)
        replace(app.textFields["nutrition.shortcuts"],with:"200,350")
        app.buttons["nutrition.shortcuts.save"].tap()
        tap(app.buttons["+200 ml"],in:app)
        XCTAssertTrue(app.staticTexts["Su tüketimi: 200 ml"].exists)
        tap(app.buttons["nutrition.plan.add"],in:app)
        replace(app.textFields["nutrition.plan.amount"],with:"500")
        app.buttons["nutrition.plan.save"].tap()
        XCTAssertTrue(app.staticTexts["Planlanan: 500 · Gerçekleşen: 0 kcal"].waitForExistence(timeout:5))
        capture(app,name:"MIHEN-Nutrition-Planning-TR")
    }
    @MainActor func testExecutiveReportAndOfflineCityGallery() throws {
        let app=start()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"],with:"Odaklı bir adım")
        replace(app.textFields["target"],with:"6")
        app.buttons["task.save"].tap()
        app.buttons["Bir artır"].tap();app.buttons["Bir artır"].tap()
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"],in:app)
        tap(app.buttons["+250 ml"],in:app)
        app.tabBars.buttons["İlerleme"].tap()
        tap(app.buttons["progress.reports"],in:app)
        XCTAssertTrue(app.staticTexts["Emeğinin görünümü"].waitForExistence(timeout:15))
        capture(app,name:"MIHEN-Executive-Report-TR")
        reveal(app.descendants(matching:.any)["report.trend.chart"].firstMatch,in:app)
        capture(app,name:"MIHEN-Report-Trend-TR")
        tap(app.buttons["report.area.health"],in:app)
        let water=app.descendants(matching:.any).matching(NSPredicate(format:"identifier BEGINSWITH %@","report.metric.activity.")).firstMatch
        XCTAssertTrue(water.waitForExistence(timeout:5));XCTAssertEqual(water.value as? String,"250 ml")
        capture(app,name:"MIHEN-Report-Health-TR")
        app.navigationBars.buttons.element(boundBy:0).tap()
        tap(app.buttons["report.analysis"],in:app)
        XCTAssertTrue(app.staticTexts["Kayıt kapsamı"].waitForExistence(timeout:10))
        capture(app,name:"MIHEN-Report-Comparison-TR")
        spiritual("prayer",in:app)
        tap(app.buttons["Konum ve hesap ayarları"],in:app)
        tap(app.buttons["prayer.city.choose"],in:app)
        capture(app,name:"MIHEN-Prayer-Cities-TR")
        tap(app.buttons["city.ankara"],in:app)
        reveal(app.textFields["latitude"],in:app)
        XCTAssertEqual(app.textFields["latitude"].value as? String,"39,9334")
        if app.buttons["keyboard.done"].firstMatch.exists { app.buttons["keyboard.done"].firstMatch.tap() }
        tap(app.buttons["prayer.city.choose"],in:app)
        let citySearch=app.searchFields.firstMatch
        tap(citySearch,in:app);citySearch.typeText("İstanbul")
        tap(app.buttons["city.istanbul"],in:app)
        reveal(app.staticTexts["İstanbul · Türkiye"],in:app)
        XCTAssertTrue(app.staticTexts["İstanbul · Türkiye"].exists)
    }
    @MainActor func testGuidedAreaExampleRequiresExplicitConfirmation() throws {
        let app=start()
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["plan.area.career"],in:app)
        tap(app.buttons["domain.example"],in:app)
        XCTAssertTrue(app.textFields.matching(NSPredicate(format:"value == %@","Seçtiğim sertifika için hazırlan")).firstMatch.exists)
        capture(app,name:"MIHEN-Guided-Example-TR")
        tap(app.buttons["example.apply"],in:app)
        let confirm=app.buttons["example.confirm"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout:5));confirm.tap()
        reveal(app.staticTexts["example.applied"],in:app)
        XCTAssertFalse(app.buttons["example.apply"].exists)
        tap(app.buttons["Hedefler"],in:app)
        let goal=app.staticTexts["Seçtiğim sertifika için hazırlan"]
        XCTAssertTrue(goal.waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["0 / 1 Adet"].exists)
    }
    @MainActor func testExecutiveReportLargeTypeNavigation() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-testing","--ui-text-ax5"];app.launch()
        XCTAssertTrue(app.buttons["onboarding.skip"].waitForExistence(timeout:10));app.buttons["onboarding.skip"].tap()
        app.tabBars.buttons["İlerleme"].tap()
        tap(app.buttons["progress.reports"],in:app)
        let heading=app.staticTexts["Yeni bir başlangıç"]
        reveal(heading,in:app)
        XCTAssertLessThanOrEqual(heading.frame.maxX,app.frame.maxX)
        XCTAssertGreaterThanOrEqual(heading.frame.minX,app.frame.minX)
        try app.performAccessibilityAudit(for:[.sufficientElementDescription])
        capture(app,name:"MIHEN-Executive-LargeText-TR")
        let area=app.buttons["report.area.learning"]
        for _ in 0..<24 { if area.exists && area.isHittable { break };app.swipeUp() }
        XCTAssertTrue(area.exists && area.isHittable)
        area.tap()
        reveal(app.buttons["report.openArea"],in:app)
        XCTAssertTrue(app.buttons["report.openArea"].exists)
    }
    @MainActor func testNewModuleScreensGallery() throws {
        let app = start()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"], with: "Sabah yürüyüşü")
        app.buttons["task.save"].tap()
        XCTAssertTrue(app.staticTexts["Sabah yürüyüşü"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Plan"].tap()
        tap(app.descendants(matching: .any)["plan.weekly"].firstMatch, in: app)
        let weeklyTask = app.staticTexts["Sabah yürüyüşü"].firstMatch
        for _ in 0..<5 { if weeklyTask.exists && weeklyTask.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(weeklyTask.exists)
        capture(app, name: "MIHEN-WeeklyPlan-TR")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        tap(app.descendants(matching: .any)["plan.routines"].firstMatch, in: app)
        tap(app.buttons["routine.add"], in: app)
        replace(app.textFields["routine.title"], with: "Sabah rutini")
        let routineTask = app.switches["Sabah yürüyüşü"]
        reveal(routineTask,in:app)
        routineTask.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(routineTask.value as? String, "1")
        tap(app.buttons["routine.save"], in: app)
        let routineGroup = app.staticTexts.matching(NSPredicate(format: "identifier BEGINSWITH %@", "routine.group.")).firstMatch
        for _ in 0..<4 { if routineGroup.exists && routineGroup.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(routineGroup.waitForExistence(timeout: 5))
        capture(app, name: "MIHEN-Routines-TR")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        tap(app.descendants(matching: .any)["plan.qada"].firstMatch, in: app)
        tap(app.descendants(matching: .any)["qada.kind"].firstMatch, in: app)
        app.buttons["Takip edilecek miktar ekle"].tap()
        replace(app.textFields["amount"], with: "10")
        tap(app.buttons["qada.save"], in: app)
        tap(app.descendants(matching: .any)["qada.kind"].firstMatch, in: app)
        app.buttons["Kılınan miktar kaydet"].tap()
        replace(app.textFields["amount"], with: "2")
        tap(app.buttons["qada.save"], in: app)
        for _ in 0..<3 { app.swipeDown() }
        XCTAssertEqual(app.staticTexts["qada.remaining.fajr"].label, "8")
        capture(app, name: "MIHEN-Qada-TR")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["plan.add"].tap()
        replace(app.textFields["goal.title"], with: "Yıllık hareket hedefi")
        replace(app.textFields["target"], with: "365")
        app.buttons["goal.save"].tap()
        tap(app.descendants(matching: .any)["plan.goals"].firstMatch, in: app)
        tap(app.staticTexts["Yıllık hareket hedefi"], in: app)
        tap(app.descendants(matching: .any)["goal.split.open"].firstMatch, in: app)
        XCTAssertTrue(app.staticTexts["Yıllık hareket hedefi"].waitForExistence(timeout: 5))
        capture(app, name: "MIHEN-GoalSplit-TR")
        let suggestion = app.staticTexts["goal.split.suggestion"]
        for _ in 0..<5 { if suggestion.exists && suggestion.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(suggestion.exists)
        capture(app, name: "MIHEN-GoalSplit-Preview-TR")
        app.tabBars.buttons["İlerleme"].tap()
        tap(app.buttons["progress.reports"], in:app)
        tap(app.buttons["report.area.spiritual"],in:app)
        let balance = app.descendants(matching:.any)["report.metric.fajrclosing"].firstMatch
        for _ in 0..<10 { if balance.exists && balance.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(balance.waitForExistence(timeout:5))
        XCTAssertEqual(balance.value as? String, "8 Sabah")
        capture(app,name:"MIHEN-Reports-Qada-TR")

    }
    @MainActor func testNutritionPersistsManualCalories() throws {
        let app = start(persistent: true)
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"], in: app)
        replace(app.textFields["amount"], with: "450")
        tap(app.buttons["Kaydet"], in: app)
        reveal(app.staticTexts["Alınan enerji: 450 kcal"],in:app)
        XCTAssertTrue(app.staticTexts["Alınan enerji: 450 kcal"].exists)
        capture(app, name: "MIHEN-Nutrition-TR")
        app.terminate(); app.launch()
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"], in: app)
        reveal(app.staticTexts["Alınan enerji: 450 kcal"],in:app)
        XCTAssertTrue(app.staticTexts["Alınan enerji: 450 kcal"].exists)
    }
    @MainActor func testOfflinePrayerTimes() throws {
        let app = start()
        app.tabBars.buttons["Plan"].tap()
        tap(app.descendants(matching: .any)["plan.spiritual"].firstMatch, in: app)
        tap(app.buttons["Namaz vakitleri"], in: app)
        tap(app.buttons["Konum ve hesap ayarları"], in: app)
        tap(app.buttons["İstanbul konumunu kullan"], in: app)
        XCTAssertEqual(app.textFields["latitude"].value as? String, "41,0082")
        tap(app.textFields["longitude"], in: app)
        XCTAssertEqual(app.textFields["longitude"].value as? String, "28,9784")
        if app.buttons["keyboard.done"].firstMatch.exists { app.buttons["keyboard.done"].firstMatch.tap() }
        tap(app.buttons["Kaydet"], in: app)
        XCTAssertTrue(app.staticTexts["Widget için kaydedildi"].exists)
        tap(app.buttons["Konum ve hesap ayarları"], in: app)
        for _ in 0..<3 { app.swipeDown() }
        XCTAssertTrue(app.staticTexts["Güneş"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["06:16"].exists, "Istanbul 15 Nov 2026 fajr must display Istanbul time, not UTC")
        capture(app, name: "MIHEN-Prayer-TR")
    }
    @MainActor func testScreenTimeSetupDoesNotRequestPermissionOnEntry() throws {
        let app = start()
        app.tabBars.buttons["Profil"].tap()
        tap(app.descendants(matching: .any)["settings.screentime"].firstMatch, in: app)
        XCTAssertTrue(app.buttons["Ekran Süresi izni ver"].waitForExistence(timeout: 5))
        let enable = app.buttons["Günlük sınırı etkinleştir"]
        for _ in 0..<6 { if enable.exists { break }; app.swipeUp() }
        XCTAssertTrue(enable.waitForExistence(timeout: 5))
        XCTAssertFalse(enable.isEnabled)
        XCTAssertFalse(app.buttons["Uygulama ve kategorileri seç"].isEnabled)
        capture(app, name: "MIHEN-ScreenTime-TR")
    }
    @MainActor func testReportsNavigation() throws {
        let app = start()
        app.tabBars.buttons["İlerleme"].tap()
        tap(app.buttons["progress.reports"], in: app)
        XCTAssertTrue(app.staticTexts["Yeni bir başlangıç"].waitForExistence(timeout:10))
        capture(app, name: "MIHEN-Reports-TR")
        reveal(app.descendants(matching:.any)["report.coverage.days"].firstMatch,in:app)
        app.buttons["report.export.open"].tap()
        capture(app,name:"MIHEN-Report-Export-TR")
        let exportButton=app.buttons["report.export.confirm"]
        for _ in 0..<8 { if exportButton.exists && exportButton.isHittable { break };app.swipeUp() }
        XCTAssertTrue(exportButton.exists)
        XCTAssertFalse(exportButton.isEnabled, "Sharing requires an explicit life-area selection")
    }
    @MainActor func testOnboardingLinkedGoalPartialCompletionAndPersistence() throws {
        let app = start(persistent: true)
        app.tabBars.buttons["Plan"].tap()
        app.buttons["plan.add"].tap()
        replace(app.textFields["goal.title"], with: "Kitap hedefi")
        replace(app.textFields["target"], with: "6")
        app.buttons["goal.save"].tap()
        app.tabBars.buttons["Bugün"].tap()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"], with: "Gunluk okuma")
        replace(app.textFields["target"], with: "6")
        app.descendants(matching: .any)["task.goal"].firstMatch.tap()
        app.buttons["Kitap hedefi"].tap()
        app.buttons["task.save"].tap()
        let increase = app.buttons["Bir artır"]
        XCTAssertTrue(increase.waitForExistence(timeout: 5))
        increase.tap(); increase.tap()
        XCTAssertTrue(app.staticTexts["Kısmen tamamlandı"].exists)
        XCTAssertTrue(app.staticTexts["2 / 6 Adet"].exists)
        XCTAssertEqual(app.staticTexts["today.effort"].label, "0 tamamlandı · 1 işe başlandı")
        capture(app, name: "MIHEN-Today-Partial-TR")
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "occurrence.complete.")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Tamamlandı"].exists)
        app.terminate(); app.launch()
        XCTAssertTrue(app.staticTexts["Gunluk okuma"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Tamamlandı"].exists)
        capture(app, name: "MIHEN-Today-TR")
    }
    @MainActor func testLanguageAndLightDarkThemes() throws {
        let app = start()
        app.tabBars.buttons["Profil"].tap()
        app.descendants(matching: .any)["settings.language"].firstMatch.tap()
        app.buttons["English"].tap()
        XCTAssertTrue(app.tabBars.buttons["Profile"].waitForExistence(timeout: 5))
        app.descendants(matching: .any)["settings.theme"].firstMatch.tap()
        app.buttons["Dark"].tap()
        capture(app, name: "MIHEN-Profile-Dark-EN")
        app.descendants(matching: .any)["settings.theme"].firstMatch.tap()
        app.buttons["Light"].tap()
        capture(app, name: "MIHEN-Profile-Light-EN")
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.buttons["today.add"].exists)
        capture(app, name: "MIHEN-Today-Light-EN")
    }
    @MainActor func testKhatmCalendarProgressAndMainTabs() throws {
        let app = start()
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"], with: "Takvim gorevi")
        app.buttons["task.save"].tap()
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "occurrence.complete.")).firstMatch.tap()
        app.tabBars.buttons["Plan"].tap()
        capture(app, name: "MIHEN-Plan-TR")
        spiritual("khatm", in: app)
        app.buttons["khatm.add"].tap()
        replace(app.textFields["khatm.title"], with: "Test hatim")
        app.buttons["khatm.save"].tap()
        app.staticTexts["Test hatim"].tap()
        replace(app.textFields["khatm.pages"], with: "6")
        app.buttons["khatm.reading.save"].tap()
        XCTAssertTrue(app.staticTexts["6 / 604 Sayfa"].exists)
        capture(app, name: "MIHEN-Khatm-TR")
        app.tabBars.buttons["Takvim"].tap()
        XCTAssertTrue(app.staticTexts["Takvim gorevi"].waitForExistence(timeout: 5))
        capture(app, name: "MIHEN-Calendar-TR")
        app.tabBars.buttons["İlerleme"].tap()
        XCTAssertTrue(app.staticTexts["1 / 1 görev tamamlandı"].exists)
        capture(app, name: "MIHEN-Progress-TR")
    }
    @MainActor func testFastingPlannedAndCompletedRemainDistinct() throws {
        let app = start()
        spiritual("fasting", in: app)
        replace(app.textFields["tracker.title"], with: "Kisisel oruc")
        app.buttons["Ekle"].tap()
        XCTAssertTrue(app.staticTexts["Planlı kayıtlar: 1"].exists)
        XCTAssertTrue(app.staticTexts["Tutulan oruç kayıtları: 0"].exists)
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "fast.status.")).firstMatch.tap()
        app.buttons["Tamamlandı"].tap()
        XCTAssertTrue(app.staticTexts["Tutulan oruç kayıtları: 1"].exists)
        capture(app, name: "MIHEN-Fasting-TR")
    }
    @MainActor func testMemorizationAndNextReview() throws {
        let app = start()
        spiritual("memorization", in: app)
        app.buttons["memorization.add"].tap()
        replace(app.textFields["memorization.title"], with: "Ezber denemesi")
        replace(app.textFields["memorization.last"], with: "10")
        replace(app.textFields["memorization.learned"], with: "2")
        app.buttons["memorization.save"].tap()
        XCTAssertTrue(app.staticTexts["2 / 10 Ayet"].exists)
        app.buttons["Tekrar yaptım"].tap()
        XCTAssertFalse(app.buttons["memorization.save"].waitForExistence(timeout: 2), "Recording a review must not open the edit sheet")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Sonraki tekrar:")).firstMatch.exists)
        capture(app, name: "MIHEN-Memorization-TR")
        tap(app.buttons["review.undo"],in:app)
        XCTAssertFalse(app.buttons["review.undo"].exists)
        app.buttons["Tekrar yaptım"].tap()
        XCTAssertTrue(app.buttons["review.undo"].exists)
    }
    @MainActor func testDhikrCounterIncreaseDecrease() throws {
        let app = start()
        spiritual("dhikr", in: app)
        replace(app.textFields["tracker.title"], with: "Zikir denemesi")
        replace(app.textFields["counter.target"], with: "3")
        app.buttons["Ekle"].tap()
        app.buttons["Bir artır"].tap(); app.buttons["Bir artır"].tap(); app.buttons["Bir artır"].tap()
        XCTAssertTrue(app.staticTexts["3 / 3"].exists)
        app.buttons["Bir azalt"].tap()
        XCTAssertTrue(app.staticTexts["2 / 3"].exists)
        capture(app, name: "MIHEN-Dhikr-TR")
    }
    @MainActor func testGuidedOnboardingExplicitTemplatesAndQuickTaskUndo() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.buttons["onboarding.continue"].waitForExistence(timeout: 10))
        capture(app, name: "MIHEN-Onboarding-TR")
        tap(app.buttons["onboarding.continue"],in:app)
        tap(app.switches["onboarding.area.health"], in: app)
        tap(app.buttons["onboarding.continue"], in: app)
        let movement = app.switches["onboarding.template.movement"]
        tap(movement, in: app)
        if movement.value as? String != "1" { movement.coordinate(withNormalizedOffset:CGVector(dx:0.9,dy:0.5)).tap() }
        XCTAssertEqual(movement.value as? String, "1")
        capture(app, name: "MIHEN-Onboarding-Choices-TR")
        tap(app.buttons["template.preview"],in:app)
        XCTAssertTrue(app.staticTexts["7 planlanan adım; miktarlar ayrı birimlerle gösterilir."].exists)
        capture(app,name:"MIHEN-Template-Week-TR")
        app.navigationBars.buttons.element(boundBy:0).tap()
        tap(app.buttons["onboarding.start"], in: app)
        XCTAssertTrue(app.staticTexts["Hareket / egzersiz"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["0 / 30 Dakika"].exists)
        XCTAssertFalse(app.staticTexts["Aileyle vakit"].exists)
        app.buttons["today.add"].tap()
        replace(app.textFields["task.title"], with:"Kısa bir mola")
        app.buttons["task.save"].tap()
        XCTAssertTrue(app.staticTexts["Kısa bir mola"].waitForExistence(timeout:5))
        app.buttons["Bir artır"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["1 / 30 Dakika"].exists)
        app.buttons["today.undo"].tap()
        XCTAssertTrue(app.staticTexts["0 / 30 Dakika"].exists)
        capture(app, name:"MIHEN-Today-Guided-TR")
        app.tabBars.buttons["Profil"].tap()
        XCTAssertTrue(app.descendants(matching:.any)["settings.language"].firstMatch.exists)
    }
    @MainActor func testBackupInformationAndNutritionQuickWater() throws {
        let app = start()
        capture(app,name:"MIHEN-Today-Empty-TR")
        app.tabBars.buttons["Profil"].tap()
        tap(app.descendants(matching:.any)["backup.details"].firstMatch,in:app)
        let scope = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "JSON yedeği kayıtları")).firstMatch
        for _ in 0..<12 { if scope.exists && scope.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(scope.waitForExistence(timeout:5))
        capture(app,name:"MIHEN-Backup-TR")
        tap(app.descendants(matching:.any)["settings.help"].firstMatch,in:app)
        capture(app,name:"MIHEN-Help-TR")
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"],in:app)
        tap(app.buttons["+250 ml"],in:app)
        XCTAssertTrue(app.staticTexts["Su tüketimi: 250 ml"].exists)
        tap(app.buttons["Geri al"],in:app)
        reveal(app.staticTexts["Su tüketimi: 0 ml"],in:app)
        XCTAssertTrue(app.staticTexts["Su tüketimi: 0 ml"].exists)
        capture(app,name:"MIHEN-Nutrition-Quick-TR")
    }

    @MainActor func testAccessibilityDescriptionsAndDynamicTypeOnFirstUse() throws {
        // The Xcode 26 SwiftUI Dynamic Type heuristic reported partial support
        // for semantic body text. Measure actual rendered growth instead of
        // suppressing audit issues or treating the heuristic as proof of resizing.
        var measurements: [[String: Double]] = []
        for flag in ["--ui-text-xs", "--ui-text-ax5"] {
            let sized = XCUIApplication(); sized.launchArguments=["--ui-testing",flag]; sized.launch()
            XCTAssertTrue(sized.buttons["onboarding.skip"].waitForExistence(timeout:10))
            let privacy = sized.staticTexts["onboarding.privacy"]
            for _ in 0..<12 { if privacy.exists && privacy.isHittable { break }; sized.swipeUp() }
            XCTAssertTrue(privacy.exists && privacy.isHittable)
            let privacyHeight = privacy.frame.height
            let action = sized.buttons["onboarding.continue"]
            for _ in 0..<12 { if action.exists && action.isHittable { break }; sized.swipeUp() }
            XCTAssertTrue(action.exists && action.isHittable)
            measurements.append(["privacyHeight":privacyHeight,"actionHeight":action.frame.height])
            capture(sized,name:flag == "--ui-text-xs" ? "MIHEN-Onboarding-SmallText-TR" : "MIHEN-Onboarding-LargeText-TR")
            sized.terminate()
        }
        XCTAssertGreaterThan(measurements[1]["privacyHeight"]!, measurements[0]["privacyHeight"]! * 1.5)
        XCTAssertGreaterThan(measurements[1]["actionHeight"]!, measurements[0]["actionHeight"]! * 1.2)
        let dimensions = try JSONSerialization.data(withJSONObject: measurements, options:.prettyPrinted)
        let proof = XCTAttachment(data:dimensions,uniformTypeIdentifier:"public.json")
        proof.name="MIHEN-DynamicType-Measurements";proof.lifetime = .keepAlways;add(proof)
        let app=XCUIApplication();app.launchArguments=["--ui-testing"];app.launch()
        XCTAssertTrue(app.buttons["onboarding.skip"].waitForExistence(timeout:10))
        try app.performAccessibilityAudit(for:[.sufficientElementDescription])
        app.buttons["onboarding.skip"].tap()
        XCTAssertTrue(app.buttons["today.add"].waitForExistence(timeout:5))
        try app.performAccessibilityAudit(for:[.sufficientElementDescription])
        capture(app,name:app.frame.width <= 375 ? "MIHEN-Today-LargeText-TR" : "MIHEN-Today-Accessibility-TR")
        if app.frame.width <= 375 {
            app.buttons["today.add"].tap()
            replace(app.textFields["task.title"], with:"Kısa yürüyüş")
            app.buttons["task.save"].tap()
            let title = app.staticTexts["Kısa yürüyüş"].firstMatch
            XCTAssertTrue(title.waitForExistence(timeout:5))
            let detail = app.buttons.containing(.staticText, identifier:"Kısa yürüyüş").firstMatch
            reveal(detail, in:app)
            capture(app,name:"MIHEN-Today-LargeText-Task-TR")
            detail.tap()
            XCTAssertTrue(app.navigationBars["Görev ayrıntısı"].waitForExistence(timeout:5))
        }
    }

}
