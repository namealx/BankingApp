//
//  AuthViews.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
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
                    Text("app_name".localized)
                        .font(.largeTitle.bold())
                    Text("login_subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Login Form
                VStack(spacing: 16) {
                    TextField("login_placeholder".localized, text: $authVM.login)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("loginField")
                    
                    SecureField("password_placeholder".localized, text: $authVM.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.oneTimeCode)
                        .disabled(authVM.isLoading)
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
                    if authVM.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("login_button".localized)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(authVM.isLoading)
                .accessibilityIdentifier("loginButton")
                
                // MARK: - Demo Button
                Button(action: {
                    authVM.login = "demo"
                    authVM.password = "demo123"
                }) {
                    Text("use_demo".localized)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .disabled(authVM.isLoading)
                .accessibilityIdentifier("demoButton")
                
                Spacer()
                
                // MARK: - Register Link
                Button(action: { showRegister = true }) {
                    Text("no_account".localized)
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
                .disabled(authVM.isLoading)
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
                Section("section_personal".localized) {
                    TextField("full_name_placeholder".localized, text: $authVM.fullName)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("fullNameField")
                    
                    TextField("email_placeholder".localized, text: $authVM.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("emailField")
                    
                    TextField("phone_placeholder".localized, text: $authVM.phone)
                        .keyboardType(.phonePad)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("phoneField")
                }
                
                // MARK: - Credentials
                Section("section_credentials".localized) {
                    TextField("login_placeholder".localized, text: $authVM.login)
                        .autocapitalization(.none)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("regLoginField")
                    
                    SecureField("password_placeholder".localized, text: $authVM.password)
                        .disabled(authVM.isLoading)
                        .accessibilityIdentifier("regPasswordField")
                    
                    SecureField("confirm_password_placeholder".localized, text: $authVM.confirmPassword)
                        .disabled(authVM.isLoading)
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
                    Button("register_button".localized) {
                        authVM.performRegister()
                        if authVM.isLoggedIn { dismiss() }
                    }
                    .disabled(authVM.isLoading)
                    .accessibilityIdentifier("registerButton")
                }
            }
            .navigationTitle("register_title".localized)
            .navigationBarItems(leading: Button("cancel".localized) {
                authVM.resetForm()
                dismiss()
            })
        }
    }
}
