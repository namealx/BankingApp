//
//  AuthViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import Combine

// MARK: - AuthViewModel
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    private let db = DatabaseManager.shared
    private let settings = SettingsManager.shared
    
    // MARK: - Init
    init() {
        // Проверяем, запущены ли UI-тесты
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            // Для тестов: принудительно выходим из аккаунта
            settings.logout()
            currentUser = nil
            isLoggedIn = false
            return
        }
        checkAutoLogin()
    }
    
    // MARK: - Auto Login
    private func checkAutoLogin() {
        if let userId = settings.currentUserId,
           let user = try? db.getUser(id: userId) {
            currentUser = user
            isLoggedIn = true
        }
    }
    
    // MARK: - Login
    func performLogin() {
        guard !login.isEmpty, !password.isEmpty else {
            errorMessage = "error_fill_fields".localized
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                if let user = try self?.db.login(login: self?.login ?? "", password: self?.password ?? "") {
                    DispatchQueue.main.async {
                        self?.currentUser = user
                        self?.settings.currentUserId = user.id
                        self?.isLoggedIn = true
                        self?.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "error_invalid_credentials".localized
                        self?.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Register
    func performRegister() {
        guard validateRegistration() else { return }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                if try self?.db.isLoginExists(self?.login ?? "") == true {
                    DispatchQueue.main.async {
                        self?.errorMessage = "error_login_exists".localized
                        self?.isLoading = false
                    }
                    return
                }
                
                let user = User(
                    fullName: self?.fullName ?? "",
                    email: self?.email ?? "",
                    phone: self?.phone ?? "",
                    login: self?.login ?? "",
                    password: self?.password ?? ""
                )
                
                let userId = try self?.db.register(user: user)
                
                if let userId = userId, let newUser = try self?.db.getUser(id: userId) {
                    DispatchQueue.main.async {
                        self?.currentUser = newUser
                        self?.settings.currentUserId = newUser.id
                        self?.isLoggedIn = true
                        self?.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        settings.logout()
        currentUser = nil
        isLoggedIn = false
        login = ""
        password = ""
        fullName = ""
        email = ""
        phone = ""
        confirmPassword = ""
        errorMessage = ""
    }
    
    // MARK: - Validation
    private func validateRegistration() -> Bool {
        guard !fullName.isEmpty else {
            errorMessage = "error_fill_name".localized
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "error_invalid_email".localized
            return false
        }
        guard !phone.isEmpty else {
            errorMessage = "error_fill_phone".localized
            return false
        }
        guard !login.isEmpty else {
            errorMessage = "error_fill_login".localized
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "error_password_short".localized
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "error_passwords_mismatch".localized
            return false
        }
        return true
    }
    
    // MARK: - Reset Form
    func resetForm() {
        fullName = ""
        email = ""
        phone = ""
        login = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
    }
}
