//
//  BankingAppTests.swift
//  BankingAppTests
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import XCTest
@testable import BankingApp

final class BankingAppTests: XCTestCase {
    
    override func setUpWithError() throws {
        super.setUp()
        let settings = SettingsManager.shared
        settings.logout()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    // MARK: - AuthViewModel Tests
    
    func testAuthViewModel_loginWithValidCredentials_succeeds() {
        let vm = AuthViewModel()
        vm.login = "demo"
        vm.password = "demo123"
        vm.performLogin()
        
        let expectation = XCTestExpectation(description: "Login completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(vm.isLoggedIn)
        XCTAssertNotNil(vm.currentUser)
    }
    
    func testAuthViewModel_loginWithInvalidCredentials_fails() {
        let vm = AuthViewModel()
        vm.login = "wronguser"
        vm.password = "wrongpass"
        vm.performLogin()
        
        let expectation = XCTestExpectation(description: "Login completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isLoggedIn)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testAuthViewModel_loginWithEmptyFields_fails() {
        let vm = AuthViewModel()
        vm.login = ""
        vm.password = ""
        vm.performLogin()
        
        XCTAssertFalse(vm.isLoggedIn)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testAuthViewModel_registerWithShortPassword_fails() {
        let vm = AuthViewModel()
        vm.fullName = "Test User"
        vm.email = "test@test.com"
        vm.phone = "+375291111111"
        vm.login = "testuser_\(Int.random(in: 10000...99999))"
        vm.password = "123"
        vm.confirmPassword = "123"
        vm.performRegister()
        
        let expectation = XCTestExpectation(description: "Register completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isLoggedIn)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testAuthViewModel_registerWithMismatchedPasswords_fails() {
        let vm = AuthViewModel()
        vm.fullName = "Test User"
        vm.email = "test2@test.com"
        vm.phone = "+375291111111"
        vm.login = "testuser2_\(Int.random(in: 10000...99999))"
        vm.password = "password123"
        vm.confirmPassword = "differentpassword"
        vm.performRegister()
        
        let expectation = XCTestExpectation(description: "Register completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isLoggedIn)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testAuthViewModel_logout_clearsUser() {
        let vm = AuthViewModel()
        vm.login = "demo"
        vm.password = "demo123"
        vm.performLogin()
        
        let expectation = XCTestExpectation(description: "Login completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(vm.isLoggedIn)
        vm.logout()
        XCTAssertFalse(vm.isLoggedIn)
        XCTAssertNil(vm.currentUser)
    }
    
    // MARK: - Account Type Localization Tests
    
    func testAccount_typeLocalization_notEmpty() {
        for type in AccountType.allCases {
            XCTAssertFalse(type.localizedName.isEmpty)
        }
    }
    
    // MARK: - Transaction Type Localization Tests
    
    func testTransaction_typeLocalization_notEmpty() {
        for type in TransactionType.allCases {
            XCTAssertFalse(type.localizedName.isEmpty)
        }
    }
    
    // MARK: - TransferViewModel Tests
    
    func testTransferViewModel_belowMinAmount_fails() {
        let vm = TransferViewModel()
        
        let from = Account(
            id: 1, userId: 1, name: "From", type: .current,
            currency: "BYN", balance: 1000, isActive: true
        )
        let to = Account(
            id: 2, userId: 1, name: "To", type: .savings,
            currency: "BYN", balance: 500, isActive: true
        )
        
        vm.fromAccount = from
        vm.toAccount = to
        vm.amountString = "0.001"
        vm.performTransfer(accounts: [from, to])
        
        let expectation = XCTestExpectation(description: "Transfer completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isTransferComplete)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testTransferViewModel_aboveMaxAmount_fails() {
        let vm = TransferViewModel()
        
        let from = Account(
            id: 1, userId: 1, name: "From", type: .current,
            currency: "BYN", balance: 99999, isActive: true
        )
        let to = Account(
            id: 2, userId: 1, name: "To", type: .savings,
            currency: "BYN", balance: 0, isActive: true
        )
        
        vm.fromAccount = from
        vm.toAccount = to
        vm.amountString = "15000"
        vm.performTransfer(accounts: [from, to])
        
        let expectation = XCTestExpectation(description: "Transfer completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isTransferComplete)
        XCTAssertFalse(vm.errorMessage.isEmpty)
    }
    
    func testTransferViewModel_sameAccount_fails() {
        let vm = TransferViewModel()
        
        let acc = Account(
            id: 1, userId: 1, name: "Same", type: .current,
            currency: "BYN", balance: 1000, isActive: true
        )
        
        vm.fromAccount = acc
        vm.toAccount = acc
        vm.amountString = "100"
        vm.performTransfer(accounts: [acc])
        
        let expectation = XCTestExpectation(description: "Transfer completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isTransferComplete)
    }
    
    func testTransferViewModel_insufficientFunds_fails() {
        let vm = TransferViewModel()
        
        let from = Account(
            id: 1, userId: 1, name: "From", type: .current,
            currency: "BYN", balance: 10, isActive: true
        )
        let to = Account(
            id: 2, userId: 1, name: "To", type: .savings,
            currency: "BYN", balance: 0, isActive: true
        )
        
        vm.fromAccount = from
        vm.toAccount = to
        vm.amountString = "100"
        vm.performTransfer(accounts: [from, to])
        
        let expectation = XCTestExpectation(description: "Transfer completes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.isTransferComplete)
    }
    
    // MARK: - CurrencyViewModel Tests
    
    func testCurrencyViewModel_loadsRates() {
        let vm = CurrencyViewModel()
        vm.loadRates()
        
        let expectation = XCTestExpectation(description: "Load rates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        XCTAssertFalse(vm.rates.isEmpty)
        XCTAssertEqual(vm.rates.count, 7)
    }
    
    func testCurrencyViewModel_convert_USD_to_BYN() {
        let vm = CurrencyViewModel()
        vm.loadRates()
        
        let expectation = XCTestExpectation(description: "Load rates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        vm.converterFromCode = "USD"
        vm.converterToCode = "BYN"
        vm.converterAmount = "1"
        vm.convert()
        
        XCTAssertFalse(vm.converterResult.isEmpty)
        let result = Double(vm.converterResult) ?? 0
        XCTAssertGreaterThan(result, 0)
    }
    
    func testCurrencyViewModel_toggleFavorite() {
        let vm = CurrencyViewModel()
        vm.loadRates()
        
        let expectation = XCTestExpectation(description: "Load rates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        let code = "GBP"
        let initialFav = vm.rates.first { $0.code == code }?.isFavorite ?? false
        vm.toggleFavorite(code: code)
        let newFav = vm.rates.first { $0.code == code }?.isFavorite ?? false
        XCTAssertNotEqual(initialFav, newFav)
    }
    
    // MARK: - SettingsManager Tests
    
    func testSettingsManager_colorSchemeDefault() {
        let settings = SettingsManager.shared
        XCTAssertNotNil(settings.colorScheme)
    }
    
    func testSettingsManager_clearCache() {
        let settings = SettingsManager.shared
        settings.clearCache()
        XCTAssertTrue(true, "Cache cleared without crash")
    }
    
    // MARK: - DatabaseManager Tests
    
    func testDatabaseManager_getBranches_notEmpty() throws {
        let branches = try DatabaseManager.shared.getBranches()
        XCTAssertGreaterThanOrEqual(branches.count, 4)
    }
    
    func testDatabaseManager_login_demo_succeeds() throws {
        let user = try DatabaseManager.shared.login(login: "demo", password: "demo123")
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.login, "demo")
    }
    
    func testDatabaseManager_getAccounts_forDemoUser() throws {
        let user = try DatabaseManager.shared.login(login: "demo", password: "demo123")
        XCTAssertNotNil(user)
        let accounts = try DatabaseManager.shared.getAccounts(userId: user!.id)
        XCTAssertGreaterThanOrEqual(accounts.count, 2)
    }
}
