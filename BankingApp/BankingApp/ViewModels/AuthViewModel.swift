//
//  AuthViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 13.05.2026
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
    
    // MARK: - Dependencies
    private let settings = SettingsManager.shared
    
    // MARK: - Login
    func performLogin() {
        guard !login.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        // Временная заглушка для демо-входа
        if login == "demo" && password == "demo123" {
            isLoggedIn = true
            errorMessage = ""
        } else {
            errorMessage = "Неверный логин или пароль"
        }
    }
    
    // MARK: - Register
    func performRegister() {
        guard !fullName.isEmpty, !email.isEmpty, !phone.isEmpty, !login.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Пароль должен быть не менее 6 символов"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return
        }
        
        
        isLoggedIn = true
        errorMessage = ""
    }
    
    // MARK: - Logout
    func logout() {
        settings.logout()
        currentUser = nil
        isLoggedIn = false
        login = ""
        password = ""
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

