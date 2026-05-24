//
//  ProfileView.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import SwiftUI
import PhotosUI

// MARK: - ProfileView
struct ProfileView: View {
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var settings: SettingsManager
    
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Avatar + Name Section
                Section {
                    HStack(spacing: 16) {
                        AvatarView(user: profileVM.user, size: 60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profileVM.user?.fullName ?? "—")
                                .font(.headline)
                            Text(profileVM.user?.email ?? "—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(profileVM.user?.phone ?? "—")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: Account Actions
                Section("Аккаунт") {
                    Button(action: { showEditProfile = true }) {
                        Label("Редактировать профиль", systemImage: "person.crop.circle")
                    }
                    .accessibilityIdentifier("editProfileButton")
                    
                    Button(action: { showChangePassword = true }) {
                        Label("Изменить пароль", systemImage: "lock.rotation")
                    }
                    .accessibilityIdentifier("changePasswordButton")
                    
                    Button(action: { showSettings = true }) {
                        Label("Настройки", systemImage: "gear")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                
                // MARK: Statistics
                Section("Статистика") {
                    let stats = getAccountStatistics()
                    HStack {
                        Text("Общий баланс")
                        Spacer()
                        Text(String(format: "%.2f BYN", stats.totalBalance))
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Всего счетов")
                        Spacer()
                        Text("\(stats.accountsCount)")
                    }
                    HStack {
                        Text("Активных счетов")
                        Spacer()
                        Text("\(stats.activeCount)")
                    }
                }
                
                // MARK: Logout
                Section {
                    Button(action: { showLogoutAlert = true }) {
                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                    .accessibilityIdentifier("logoutButton")
                }
            }
            .navigationTitle("Профиль")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(profileVM)
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
                    .environmentObject(profileVM)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
            .alert("Выход", isPresented: $showLogoutAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Выйти", role: .destructive) {
                    authVM.logout()
                }
            } message: {
                Text("Вы уверены, что хотите выйти?")
            }
            .alert("Ошибка", isPresented: .constant(!profileVM.errorMessage.isEmpty)) {
                Button("OK") { profileVM.errorMessage = "" }
            } message: {
                Text(profileVM.errorMessage)
            }
            .alert("Успех", isPresented: .constant(!profileVM.successMessage.isEmpty)) {
                Button("OK") { profileVM.successMessage = "" }
            } message: {
                Text(profileVM.successMessage)
            }
        }
    }
    
    private func getAccountStatistics() -> (totalBalance: Double, accountsCount: Int, activeCount: Int) {
        let db = DatabaseManager.shared
        guard let userId = profileVM.user?.id else { return (0, 0, 0) }
        
        do {
            let accounts = try db.getAccounts(userId: userId)
            let totalBalance = accounts.reduce(0) { $0 + $1.balance }
            let activeCount = accounts.filter { $0.isActive }.count
            return (totalBalance, accounts.count, activeCount)
        } catch {
            return (0, 0, 0)
        }
    }
}

// MARK: - AvatarView
struct AvatarView: View {
    let user: User?
    let size: CGFloat
    
    var body: some View {
        Group {
            if let data = user?.avatarData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.blue)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - EditProfileView
struct EditProfileView: View {
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Avatar Section
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            AvatarView(user: profileVM.user, size: 80)
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "camera.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Color.white, in: Circle())
                                }
                        }
                        .onChange(of: photoPickerItem) { _, item in
                            Task {
                                if let data = try? await item?.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    profileVM.selectedImage = img
                                }
                            }
                        }
                        .accessibilityIdentifier("avatarPicker")
                        Spacer()
                    }
                }
                
                // MARK: Personal Info Section
                Section("Личная информация") {
                    TextField("ФИО", text: $profileVM.editFullName)
                        .accessibilityIdentifier("editFullNameField")
                    
                    TextField("Email", text: $profileVM.editEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("editEmailField")
                    
                    TextField("Телефон", text: $profileVM.editPhone)
                        .keyboardType(.phonePad)
                        .accessibilityIdentifier("editPhoneField")
                }
                
                // MARK: Error/Success Messages
                if !profileVM.errorMessage.isEmpty {
                    Section {
                        Text(profileVM.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                if !profileVM.successMessage.isEmpty {
                    Section {
                        Text(profileVM.successMessage)
                            .foregroundColor(.green)
                    }
                }
                
                // MARK: Save Button
                Section {
                    Button(action: {
                        profileVM.updateProfile()
                        if profileVM.errorMessage.isEmpty {
                            dismiss()
                        }
                    }) {
                        if profileVM.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Сохранить")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(profileVM.isLoading)
                    .accessibilityIdentifier("saveProfileButton")
                }
            }
            .navigationTitle("Редактирование профиля")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        profileVM.clearForm()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ChangePasswordView
struct ChangePasswordView: View {
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Текущий пароль") {
                    SecureField("Текущий пароль", text: $profileVM.currentPassword)
                        .accessibilityIdentifier("currentPasswordField")
                }
                
                Section("Новый пароль") {
                    SecureField("Новый пароль (мин. 6 символов)", text: $profileVM.newPassword)
                        .accessibilityIdentifier("newPasswordField")
                    
                    SecureField("Подтвердите новый пароль", text: $profileVM.confirmNewPassword)
                        .accessibilityIdentifier("confirmNewPasswordField")
                }
                
                if !profileVM.errorMessage.isEmpty {
                    Section {
                        Text(profileVM.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                if !profileVM.successMessage.isEmpty {
                    Section {
                        Text(profileVM.successMessage)
                            .foregroundColor(.green)
                    }
                }
                
                Section {
                    Button(action: {
                        profileVM.changePassword()
                        if profileVM.errorMessage.isEmpty {
                            dismiss()
                        }
                    }) {
                        if profileVM.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Изменить пароль")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(profileVM.isLoading)
                    .accessibilityIdentifier("changePasswordConfirmButton")
                }
            }
            .navigationTitle("Смена пароля")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        profileVM.clearForm()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showClearCacheAlert = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Appearance
                Section("Внешний вид") {
                    Picker("Тема", selection: $settings.colorScheme) {
                        ForEach(ColorSchemePreference.allCases, id: \.self) { scheme in
                            Text(scheme.localizedName).tag(scheme)
                        }
                    }
                    .accessibilityIdentifier("themePicker")
                    
                    Picker("Язык", selection: $settings.language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.localizedName).tag(lang)
                        }
                    }
                    .accessibilityIdentifier("languagePicker")
                }
                
                // MARK: Notifications
                Section("Уведомления") {
                    Toggle("Включить уведомления", isOn: $settings.notificationsEnabled)
                        .accessibilityIdentifier("notificationsToggle")
                    
                    if settings.notificationsEnabled {
                        DatePicker("Время уведомлений",
                                   selection: $settings.notificationTime,
                                   displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("notificationTimePicker")
                    }
                }
                
                // MARK: Storage
                Section("Хранилище") {
                    Button(role: .destructive) {
                        showClearCacheAlert = true
                    } label: {
                        Label("Очистить кэш", systemImage: "trash")
                    }
                    .accessibilityIdentifier("clearCacheButton")
                }
                
                // MARK: About
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .alert("Очистка кэша", isPresented: $showClearCacheAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Очистить", role: .destructive) {
                    settings.clearCache()
                    showSuccessMessage = true
                }
            } message: {
                Text("Это действие очистит кэш приложения. Продолжить?")
            }
            .alert("Кэш очищен", isPresented: $showSuccessMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Кэш приложения успешно очищен.")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsManager.shared)
}
