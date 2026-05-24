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
    @Published var user: User?
    @Published var editFullName: String = ""
    @Published var editEmail: String = ""
    @Published var editPhone: String = ""
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmNewPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var successMessage: String = ""
    @Published var selectedImage: UIImage?
    
    func loadUser(id: Int64) {
        
    }
    
    func updateProfile() {
        
    }
    
    func changePassword() {
        
    }
}
