import XCTest
import CoreGraphics

final class NavigationTests: XCTestCase {
    @MainActor func testCoreNavigationAndScreenshots() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(tab("Keşfet", in: app).waitForExistence(timeout: 10))
        capture(app, "01-Discover")
        app.buttons["recommendMovie"].tap()
        XCTAssertTrue(app.navigationBars["SANA BİR FİLM"].waitForExistence(timeout: 5))
        capture(app, "09-Recommendation")
        app.buttons["Bitti"].tap()
        tab("Ara", in: app).tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        capture(app, "02-Search")
        tab("Listem", in: app).tap()
        XCTAssertTrue(app.buttons["Listeyi sırala"].waitForExistence(timeout: 5))
        let sortingButton = app.buttons["Listeyi sırala"]
        XCTAssertTrue(app.frame.contains(sortingButton.frame))
        // Xcode 16 attempts an unsupported AX scroll on SwiftUI toolbar menus.
        // Tap the observed on-screen center, then verify the menu actually opened.
        sortingButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["Puanıma göre"].waitForExistence(timeout: 5))
        app.buttons["Puanıma göre"].tap()
        capture(app, "03-Library")
        tab("Ayarlar", in: app).tap()
        for _ in 0..<5 {
            if app.buttons["Platform Aboneliklerim"].exists && app.buttons["Platform Aboneliklerim"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["Platform Aboneliklerim"].waitForExistence(timeout: 5))
        capture(app, "04-Settings")
        app.buttons["Platform Aboneliklerim"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        capture(app, "05-Platforms")
    }
    @MainActor func testNavigationWithLargestTextSize() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(tab("Keşfet", in: app).waitForExistence(timeout: 10))
        capture(app, "06-LargeText-Discover")
        tab("Listem", in: app).tap()
        XCTAssertTrue(app.buttons["Listeyi sırala"].waitForExistence(timeout: 5))
        capture(app, "07-LargeText-Library")
        tab("Ayarlar", in: app).tap()
        for _ in 0..<5 {
            if app.buttons["Platform Aboneliklerim"].exists && app.buttons["Platform Aboneliklerim"].isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(app.buttons["Platform Aboneliklerim"].waitForExistence(timeout: 5))
        app.buttons["Platform Aboneliklerim"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))
        capture(app, "08-LargeText-Platforms")
    }
    @MainActor private func tab(_ title: String, in app: XCUIApplication) -> XCUIElement {
        // iPad's floating tab strip is exposed as buttons, not a TabBar.
        app.buttons.matching(NSPredicate(format: "label == %@", title)).firstMatch
    }
    @MainActor private func capture(_ app: XCUIApplication, _ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
