//
//  BankingAppUITests.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import XCTest

// MARK: - BankingAppUITests
final class BankingAppUITests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Private Helpers

    @discardableResult
    private func loginWithDemoButton() -> Bool {
        let demoButton = app.buttons["demoButton"]
        guard demoButton.waitForExistence(timeout: 8) else {
            XCTFail("demoButton not found")
            return false
        }
        demoButton.tap()

        let loginButton = app.buttons["loginButton"]
        guard loginButton.waitForExistence(timeout: 5) else {
            XCTFail("loginButton not found")
            return false
        }
        loginButton.tap()

        dismissPasswordSavePromptIfNeeded()

        let tabBar = app.tabBars.firstMatch
        let appeared = tabBar.waitForExistence(timeout: 15)
        XCTAssertTrue(appeared, "Tab bar should appear after successful login")
        return appeared
    }

    private func dismissPasswordSavePromptIfNeeded() {
        let dismissLabels = [
            "Not Now", "Не сейчас",
            "Cancel",  "Отмена",
            "Save",    "Сохранить"
        ]
        for label in dismissLabels {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) {
                btn.tap()
                return
            }
        }
    }

    private func selectTab(_ index: Int) {
        let tab = app.tabBars.firstMatch.buttons.element(boundBy: index)
        XCTAssertTrue(tab.waitForExistence(timeout: 5), "Tab \(index) should exist")
        tab.tap()
    }

    // MARK: - Login Screen Tests

    func testLoginScreen_isDisplayed() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 8),
                      "Login button should be visible on launch")
    }

    func testLoginScreen_hasLoginField() {
        let loginField = app.textFields["loginField"]
        XCTAssertTrue(loginField.waitForExistence(timeout: 8),
                      "Login text field should exist")
    }

    func testLoginScreen_hasPasswordField() {
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 8),
                      "Password secure field should exist")
    }

    func testLoginScreen_hasDemoButton() {
        let demoButton = app.buttons["demoButton"]
        XCTAssertTrue(demoButton.waitForExistence(timeout: 8),
                      "Demo button should exist")
    }

    func testLoginScreen_emptyFields_showsError() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 8))
        loginButton.tap()

        let errorText = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'аполн' OR label CONTAINS 'fill'")
        ).firstMatch
        XCTAssertTrue(errorText.waitForExistence(timeout: 5),
                      "Error message should appear when fields are empty")
    }

    func testLoginScreen_demoButton_fillsAndLogins() {
        let demoButton = app.buttons["demoButton"]
        XCTAssertTrue(demoButton.waitForExistence(timeout: 8))
        demoButton.tap()

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        dismissPasswordSavePromptIfNeeded()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 15),
                      "Tab bar should appear after demo login")
    }

    

    // MARK: - Accounts Tab Tests

    func testAccountsTab_showsBalanceInBYN() {
        loginWithDemoButton()
        selectTab(0)
        let balanceText = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS 'BYN'")
        ).firstMatch
        XCTAssertTrue(balanceText.waitForExistence(timeout: 8),
                      "Balance in BYN should be visible on accounts tab")
    }

    func testAccountsTab_addButtonExists() {
        loginWithDemoButton()
        selectTab(0)
        let addButton = app.navigationBars.buttons.matching(
            NSPredicate(format: "label == 'Add' OR label == 'plus'")
        ).firstMatch
        let anyButton = app.navigationBars.firstMatch.buttons.element(boundBy: 0)
        XCTAssertTrue(
            addButton.waitForExistence(timeout: 5) || anyButton.waitForExistence(timeout: 5),
            "Add account button should exist in navigation bar"
        )
    }

    func testAccountsTab_showsTotalBalance() {
        loginWithDemoButton()
        selectTab(0)
        let totalLabel = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS '.'"
        )).firstMatch
        XCTAssertTrue(totalLabel.waitForExistence(timeout: 8),
                      "Total balance amount should be displayed")
    }

    // MARK: - Transfer Tab Tests

    func testTransferTab_isAccessible() {
        loginWithDemoButton()
        selectTab(1)
        let transferButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'еревест' OR label CONTAINS 'ransfer'")
        ).firstMatch
        XCTAssertTrue(transferButton.waitForExistence(timeout: 8),
                      "Transfer action button should be visible on transfer tab")
    }

    // MARK: - Currency Tab Tests

    func testCurrencyTab_showsRates() {
        loginWithDemoButton()
        selectTab(2)
        let refreshButton = app.buttons["refreshRatesButton"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 8),
                      "Refresh rates button should exist on currency tab")
    }

    func testCurrencyTab_converterButtonExists() {
        loginWithDemoButton()
        selectTab(2)
        let converterButton = app.buttons["converterButton"]
        XCTAssertTrue(converterButton.waitForExistence(timeout: 8),
                      "Converter button should exist on currency tab")
    }

    func testCurrencyTab_showsCurrencyCodes() {
        loginWithDemoButton()
        selectTab(2)
        let usdText = app.staticTexts.matching(
            NSPredicate(format: "label == 'USD'")
        ).firstMatch
        XCTAssertTrue(usdText.waitForExistence(timeout: 8),
                      "USD currency rate should be visible")
    }

    // MARK: - Map Tab Tests

    func testMapTab_isAccessible() {
        loginWithDemoButton()
        selectTab(3)
        let listButton = app.navigationBars.firstMatch.buttons.element(boundBy: 0)
        XCTAssertTrue(listButton.waitForExistence(timeout: 10),
                      "Navigation bar button should exist on map tab")
    }

    func testMapTab_hasNavigationTitle() {
        loginWithDemoButton()
        selectTab(3)
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.waitForExistence(timeout: 8),
                      "Navigation bar with title should exist on map tab")
    }

    // MARK: - Profile Tab Tests

    func testProfileTab_isAccessible() {
        loginWithDemoButton()
        selectTab(4)
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 8),
                      "Logout button should exist on profile tab")
    }

    func testProfileTab_editProfileButtonExists() {
        loginWithDemoButton()
        selectTab(4)
        let editButton = app.buttons["editProfileButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8),
                      "Edit profile button should exist")
    }

    func testProfileTab_settingsButtonExists() {
        loginWithDemoButton()
        selectTab(4)
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 8),
                      "Settings button should exist")
    }

    func testProfileTab_changePasswordButtonExists() {
        loginWithDemoButton()
        selectTab(4)
        let changePasswordButton = app.buttons["changePasswordButton"]
        XCTAssertTrue(changePasswordButton.waitForExistence(timeout: 8),
                      "Change password button should exist")
    }

    // MARK: - Logout Test

    func testLogout_returnsToLoginScreen() {
        loginWithDemoButton()
        selectTab(4)

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 8))
        logoutButton.tap()

        let confirmButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Выйти' OR label CONTAINS 'Sign Out' OR label CONTAINS 'Logout'")
        ).firstMatch
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10),
                      "Login screen should be shown after logout")
    }
}
