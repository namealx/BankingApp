//
//  ProfileViewModel.swift
//  BankingApp
//
//  Created by Nikita Yuranov on 24.05.2026
//  Group: 12b
//

import Foundation
import SwiftUI
import Combine

// MARK: - ProfileViewModel
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    
    // MARK: - Edit Profile Properties
    @Published var editFullName: String = ""
    @Published var editEmail: String = ""
    @Published var editPhone: String = ""
    @Published var selectedImage: UIImage?
    
    // MARK: - Change Password Properties
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    
    // MARK: - Dependencies
    private let db = DatabaseManager.shared
    
    // MARK: - Load User
    func loadUser(id: Int64) {
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                if let loadedUser = try self?.db.getUser(id: id) {
                    DispatchQueue.main.async {
                        self?.user = loadedUser
                        self?.editFullName = loadedUser.fullName
                        self?.editEmail = loadedUser.email
                        self?.editPhone = loadedUser.phone
                        self?.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Пользователь не найден"
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
    
    // MARK: - Update Profile
    func updateProfile() {
        guard var currentUser = user else { return }
        guard !editFullName.isEmpty, !editEmail.isEmpty, !editPhone.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let updatedUser = User(
            id: currentUser.id,
            fullName: editFullName,
            email: editEmail,
            phone: editPhone,
            login: currentUser.login,
            password: currentUser.password,
            avatarData: selectedImage?.jpegData(compressionQuality: 0.8) ?? currentUser.avatarData,
            createdAt: currentUser.createdAt
        )
        
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.db.updateUser(updatedUser)
                DispatchQueue.main.async {
                    self?.user = updatedUser
                    self?.successMessage = "Профиль успешно обновлен"
                    self?.isLoading = false
                    self?.selectedImage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Change Password
    func changePassword() {
        guard let currentUser = user else { return }
        
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmNewPassword.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        guard currentPassword == currentUser.password else {
            errorMessage = "Неверный текущий пароль"
            return
        }
        
        guard newPassword.count >= 6 else {
            errorMessage = "Новый пароль должен быть не менее 6 символов"
            return
        }
        
        guard newPassword == confirmNewPassword else {
            errorMessage = "Новые пароли не совпадают"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global().async { [weak self] in
            do {
                try self?.db.updatePassword(userId: currentUser.id, newPassword: self?.newPassword ?? "")
                DispatchQueue.main.async {
                    self?.successMessage = "Пароль успешно изменен"
                    self?.currentPassword = ""
                    self?.newPassword = ""
                    self?.confirmNewPassword = ""
                    self?.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Clear Form
    func clearForm() {
        editFullName = user?.fullName ?? ""
        editEmail = user?.email ?? ""
        editPhone = user?.phone ?? ""
        selectedImage = nil
        currentPassword = ""
        newPassword = ""
        confirmNewPassword = ""
        errorMessage = ""
        successMessage = ""
    }
}
