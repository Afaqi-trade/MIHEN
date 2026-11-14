import XCTest

final class MIHENUITests: XCTestCase {
    @MainActor func testOnboardingGoalTaskCompletionAndScreenshot() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--ui-test-store", UUID().uuidString]
        app.launch()
        let skip = app.buttons["onboarding.skip"]
        XCTAssertTrue(skip.waitForExistence(timeout: 10))
        skip.tap()
        app.tabBars.buttons["Plan"].tap()
        app.buttons["plan.add"].tap()
        let goalTitle = app.textFields["goal.title"]
        XCTAssertTrue(goalTitle.waitForExistence(timeout: 5))
        goalTitle.tap(); goalTitle.typeText("Kitap hedefi")
        app.buttons["goal.save"].tap()
        app.tabBars.buttons["Bugün"].tap()
        app.buttons["today.add"].tap()
        let taskTitle = app.textFields["task.title"]
        XCTAssertTrue(taskTitle.waitForExistence(timeout: 5))
        taskTitle.tap(); taskTitle.typeText("Gunluk okuma")
        app.buttons["task.save"].tap()
        let complete = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "occurrence.complete.")).firstMatch
        XCTAssertTrue(complete.waitForExistence(timeout: 5))
        complete.tap()
        XCTAssertTrue(app.staticTexts["Tamamlandı"].exists)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Gunluk okuma"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Tamamlandı"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "MIHEN-Today-TR"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor func testLanguageAndThemeControlsExist() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        app.buttons["onboarding.skip"].tap()
        app.tabBars.buttons["Profil"].tap()
        XCTAssertTrue(app.buttons["settings.language"].exists || app.otherElements["settings.language"].exists)
        XCTAssertTrue(app.buttons["settings.theme"].exists || app.otherElements["settings.theme"].exists)
    }
}
