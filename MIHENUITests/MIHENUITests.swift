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
        tap(field, in: app)
        let value = field.value as? String ?? ""
        if !value.isEmpty {
            field.press(forDuration: 1.2)
            let predicate = NSPredicate(format: "label IN %@", ["Select All", "Tümünü Seç", "Tümünü seç"])
            let selectAllButton = app.buttons.matching(predicate).firstMatch
            let selectAllMenu = app.menuItems.matching(predicate).firstMatch
            if selectAllButton.waitForExistence(timeout: 1) { selectAllButton.tap() }
            else if selectAllMenu.exists { selectAllMenu.tap() }
            else { field.tap(withNumberOfTaps: 3, numberOfTouches: 1) }
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
        XCTAssertTrue(app.staticTexts["Planlandı: 1"].exists)
        XCTAssertTrue(app.staticTexts["Tamamlandı: 0"].exists)
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "fast.status.")).firstMatch.tap()
        app.buttons["Tamamlandı"].tap()
        XCTAssertTrue(app.staticTexts["Tamamlandı: 1"].exists)
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
}
