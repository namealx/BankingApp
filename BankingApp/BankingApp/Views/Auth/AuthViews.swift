//
//  AuthViews.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 22.05.2026
//  Group: 12b
//

import SwiftUI

// MARK: - LoginView
struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // MARK: - Logo
                VStack(spacing: 8) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("BankingApp")
                        .font(.largeTitle.bold())
                    Text("Ваш надежный финансовый помощник")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Login Form
                VStack(spacing: 16) {
                    TextField("Логин", text: $authVM.login)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("loginField")
                    
                    SecureField("Пароль", text: $authVM.password)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("passwordField")
                    
                    if !authVM.errorMessage.isEmpty {
                        Text(authVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .accessibilityIdentifier("errorMessage")
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Login Button
                Button(action: authVM.performLogin) {
                    Text("Войти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .accessibilityIdentifier("loginButton")
                
                // MARK: - Demo Button
                Button(action: {
                    authVM.login = "demo"
                    authVM.password = "demo123"
                }) {
                    Text("Использовать демо-аккаунт")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .accessibilityIdentifier("demoButton")
                
                Spacer()
                
                // MARK: - Register Link
                Button(action: { showRegister = true }) {
                    Text("Нет аккаунта? Зарегистрироваться")
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
                .accessibilityIdentifier("registerNavigationButton")
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authVM)
            }
        }
    }
}

// MARK: - RegisterView
struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Personal Info
                Section("Личная информация") {
                    TextField("ФИО", text: $authVM.fullName)
                        .accessibilityIdentifier("fullNameField")
                    
                    TextField("Email", text: $authVM.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier("emailField")
                    
                    TextField("Телефон", text: $authVM.phone)
                        .keyboardType(.phonePad)
                        .accessibilityIdentifier("phoneField")
                }
                
                // MARK: - Credentials
                Section("Данные для входа") {
                    TextField("Логин", text: $authVM.login)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("regLoginField")
                    
                    SecureField("Пароль", text: $authVM.password)
                        .accessibilityIdentifier("regPasswordField")
                    
                    SecureField("Подтвердите пароль", text: $authVM.confirmPassword)
                        .accessibilityIdentifier("confirmPasswordField")
                }
                
                // MARK: - Error Message
                if !authVM.errorMessage.isEmpty {
                    Section {
                        Text(authVM.errorMessage)
                            .foregroundColor(.red)
                            .accessibilityIdentifier("registerErrorMessage")
                    }
                }
                
                // MARK: - Register Button
                Section {
                    Button("Зарегистрироваться") {
                        authVM.performRegister()
                        if authVM.isLoggedIn { dismiss() }
                    }
                    .accessibilityIdentifier("registerButton")
                }
            }
            .navigationTitle("Регистрация")
        }
    }
}

