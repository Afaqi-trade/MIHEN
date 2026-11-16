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
        let value = field.value as? String ?? ""
        if !value.isEmpty {
            let textEnd = field.coordinate(withNormalizedOffset: CGVector(dx: 0.999, dy: 0.5))
            textEnd.tap()
            textEnd.press(forDuration: 1.2)
            let predicate = NSPredicate(format: "label IN %@", ["Select All", "Tümünü Seç", "Tümünü seç"])
            let selectAllButton = app.buttons.matching(predicate).firstMatch
            let selectAllMenu = app.menuItems.matching(predicate).firstMatch
            if selectAllButton.waitForExistence(timeout: 1) { selectAllButton.tap() }
            else if selectAllMenu.exists { selectAllMenu.tap() }
            else { textEnd.tap() }
        }
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count) + text)
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
    @MainActor private func tap(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 {
            if element.exists && element.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        element.tap()
    }
    @MainActor private func spiritual(_ module: String, in app: XCUIApplication) {
        app.tabBars.buttons["Plan"].tap()
        tap(app.descendants(matching: .any)["plan.spiritual"].firstMatch, in: app)
        tap(app.descendants(matching: .any)["spiritual." + module].firstMatch, in: app)
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
        tap(app.buttons["Dönem raporları"], in:app)
        let balance = app.descendants(matching:.any)["report.metric.fajrclosing"].firstMatch
        for _ in 0..<10 { if balance.exists && balance.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(balance.waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["8 Sabah"].exists)
        capture(app,name:"MIHEN-Reports-Qada-TR")

    }
    @MainActor func testNutritionPersistsManualCalories() throws {
        let app = start(persistent: true)
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"], in: app)
        replace(app.textFields["amount"], with: "450")
        tap(app.buttons["Kaydet"], in: app)
        XCTAssertTrue(app.staticTexts["Alınan enerji: 450 kcal"].exists)
        capture(app, name: "MIHEN-Nutrition-TR")
        app.terminate(); app.launch()
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"], in: app)
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
        XCTAssertEqual(app.textFields["longitude"].value as? String, "28,9784")
        tap(app.buttons["Kaydet"], in: app)
        XCTAssertTrue(app.staticTexts["Widget için kaydedildi"].exists)
        app.swipeUp()
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
        tap(app.buttons["Dönem raporları"], in: app)
        XCTAssertTrue(app.staticTexts["Yalnızca kayıtlı veriler raporlanır. Kayıt olmayan günler başarısızlık sayılmaz."].waitForExistence(timeout: 5))
        capture(app, name: "MIHEN-Reports-TR")
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
        app.buttons["onboarding.continue"].tap()
        tap(app.switches["onboarding.area.health"], in: app)
        tap(app.buttons["onboarding.continue"], in: app)
        let movement = app.switches["onboarding.template.movement"]
        tap(movement, in: app)
        if movement.value as? String != "1" { movement.coordinate(withNormalizedOffset:CGVector(dx:0.9,dy:0.5)).tap() }
        XCTAssertEqual(movement.value as? String, "1")
        capture(app, name: "MIHEN-Onboarding-Choices-TR")
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
        let scope = app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@", "JSON yedeği kayıtlarınızı")).firstMatch
        for _ in 0..<12 { if scope.exists && scope.isHittable { break }; app.swipeUp() }
        XCTAssertTrue(scope.waitForExistence(timeout:5))
        capture(app,name:"MIHEN-Backup-TR")
        app.tabBars.buttons["Plan"].tap()
        tap(app.buttons["Beslenme ve hareket"],in:app)
        tap(app.buttons["+250 ml"],in:app)
        XCTAssertTrue(app.staticTexts["Su tüketimi: 250 ml"].exists)
        tap(app.buttons["Geri al"],in:app)
        XCTAssertTrue(app.staticTexts["Su tüketimi: 0 ml"].exists)
        capture(app,name:"MIHEN-Nutrition-Quick-TR")
    }

}
