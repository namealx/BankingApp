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
                Section("account".localized) {
                    Button(action: { showEditProfile = true }) {
                        Label("edit_profile".localized, systemImage: "person.crop.circle")
                    }
                    .accessibilityIdentifier("editProfileButton")
                    
                    Button(action: { showChangePassword = true }) {
                        Label("change_password".localized, systemImage: "lock.rotation")
                    }
                    .accessibilityIdentifier("changePasswordButton")
                    
                    Button(action: { showSettings = true }) {
                        Label("settings_title".localized, systemImage: "gear")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                
                // MARK: Statistics
                Section("statistics".localized) {
                    let stats = getAccountStatistics()
                    HStack {
                        Text("total_balance".localized)
                        Spacer()
                        Text(String(format: "%.2f BYN", stats.totalBalance))
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("total_accounts".localized)
                        Spacer()
                        Text("\(stats.accountsCount)")
                    }
                    HStack {
                        Text("active_accounts".localized)
                        Spacer()
                        Text("\(stats.activeCount)")
                    }
                }
                
                // MARK: Logout
                Section {
                    Button(action: { showLogoutAlert = true }) {
                        Label("logout".localized, systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                    .accessibilityIdentifier("logoutButton")
                }
            }
            .navigationTitle("tab_profile".localized)
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
            .alert("logout".localized, isPresented: $showLogoutAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("logout".localized, role: .destructive) {
                    authVM.logout()
                }
            } message: {
                Text("logout_confirm".localized)
            }
            .alert("error".localized, isPresented: .constant(!profileVM.errorMessage.isEmpty)) {
                Button("ok".localized) { profileVM.errorMessage = "" }
            } message: {
                Text(profileVM.errorMessage)
            }
            .alert("success".localized, isPresented: .constant(!profileVM.successMessage.isEmpty)) {
                Button("ok".localized) { profileVM.successMessage = "" }
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
                
                Section("section_personal".localized) {
                    TextField("full_name_placeholder".localized, text: $profileVM.editFullName)
                        .accessibilityIdentifier("editFullNameField")
                    
                    TextField("email_placeholder".localized, text: $profileVM.editEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("editEmailField")
                    
                    TextField("phone_placeholder".localized, text: $profileVM.editPhone)
                        .keyboardType(.phonePad)
                        .accessibilityIdentifier("editPhoneField")
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
                        profileVM.updateProfile()
                        if profileVM.errorMessage.isEmpty {
                            dismiss()
                        }
                    }) {
                        if profileVM.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("save".localized)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(profileVM.isLoading)
                    .accessibilityIdentifier("saveProfileButton")
                }
            }
            .navigationTitle("edit_profile_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
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
                Section("current_password".localized) {
                    SecureField("current_password".localized, text: $profileVM.currentPassword)
                        .accessibilityIdentifier("currentPasswordField")
                }
                
                Section("new_password".localized) {
                    SecureField("new_password_hint".localized, text: $profileVM.newPassword)
                        .accessibilityIdentifier("newPasswordField")
                    
                    SecureField("confirm_password_placeholder".localized, text: $profileVM.confirmNewPassword)
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
                            Text("change_password".localized)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(profileVM.isLoading)
                    .accessibilityIdentifier("changePasswordConfirmButton")
                }
            }
            .navigationTitle("change_password".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
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
                Section("appearance".localized) {
                    Picker("theme".localized, selection: $settings.colorScheme) {
                        ForEach(ColorSchemePreference.allCases, id: \.self) { scheme in
                            Text(scheme.localizedName).tag(scheme)
                        }
                    }
                    .accessibilityIdentifier("themePicker")
                    
                    Picker("language".localized, selection: $settings.language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.localizedName).tag(lang)
                        }
                    }
                    .accessibilityIdentifier("languagePicker")
                }
                
                // MARK: Notifications
                Section("notifications".localized) {
                    Toggle("enable_notifications".localized, isOn: $settings.notificationsEnabled)
                        .accessibilityIdentifier("notificationsToggle")
                    
                    if settings.notificationsEnabled {
                        DatePicker("notification_time".localized,
                                   selection: $settings.notificationTime,
                                   displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("notificationTimePicker")
                    }
                }
                
                // MARK: Storage
                Section("storage".localized) {
                    Button(role: .destructive) {
                        showClearCacheAlert = true
                    } label: {
                        Label("clear_cache".localized, systemImage: "trash")
                    }
                    .accessibilityIdentifier("clearCacheButton")
                }
                
                // MARK: About
                Section("about".localized) {
                    HStack {
                        Text("version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("settings_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done".localized) { dismiss() }
                }
            }
            .alert("clear_cache_title".localized, isPresented: $showClearCacheAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("clear_cache".localized, role: .destructive) {
                    settings.clearCache()
                    showSuccessMessage = true
                }
            } message: {
                Text("clear_cache_confirm".localized)
            }
            .alert("cache_cleared_title".localized, isPresented: $showSuccessMessage) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text("cache_cleared_message".localized)
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
